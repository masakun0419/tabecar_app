from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.auth.security import get_current_user
from app.database import get_db
from app.models import Favorite, Shop, User
from app.schemas import FavoriteCreateRequest, FavoriteResponse

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("", response_model=list[FavoriteResponse])
def list_favorites(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> list[dict]:
    favorites = (
        db.query(Favorite)
        .options(joinedload(Favorite.shop))
        .filter(Favorite.user_id == current_user.id)
        .order_by(Favorite.created_at.desc())
        .all()
    )
    return [
        {
            "id": favorite.id,
            "shop_id": favorite.shop_id,
            "shop_name": favorite.shop.name,
            "icon_image_url": favorite.shop.icon_image_url,
            "created_at": favorite.created_at,
        }
        for favorite in favorites
    ]


@router.post("", response_model=FavoriteResponse, status_code=status.HTTP_201_CREATED)
def create_favorite(
    payload: FavoriteCreateRequest,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> dict:
    shop = db.query(Shop).filter(Shop.id == payload.shop_id, Shop.is_published.is_(True)).first()
    if shop is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shop not found")

    existing = (
        db.query(Favorite)
        .filter(Favorite.user_id == current_user.id, Favorite.shop_id == payload.shop_id)
        .first()
    )
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Already favorited")

    favorite = Favorite(user_id=current_user.id, shop_id=payload.shop_id)
    db.add(favorite)
    db.commit()
    db.refresh(favorite)

    return {
        "id": favorite.id,
        "shop_id": favorite.shop_id,
        "shop_name": shop.name,
        "icon_image_url": shop.icon_image_url,
        "created_at": favorite.created_at,
    }


@router.delete("/{shop_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_favorite(
    shop_id: int,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> None:
    favorite = (
        db.query(Favorite)
        .filter(Favorite.user_id == current_user.id, Favorite.shop_id == shop_id)
        .first()
    )
    if favorite is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Favorite not found")

    db.delete(favorite)
    db.commit()
