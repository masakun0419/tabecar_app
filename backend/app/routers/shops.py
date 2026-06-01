from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload

from app.auth.security import get_current_user, require_shop_user
from app.database import get_db
from app.models import Shop, User
from app.schemas import ShopCreateRequest, ShopDetailResponse, ShopSummaryResponse
from app.services.geo import build_shop_summary, filter_shops_by_location, load_shops

router = APIRouter(prefix="/shops", tags=["shops"])


@router.get("", response_model=list[ShopSummaryResponse])
def list_shops(
    db: Annotated[Session, Depends(get_db)],
    latitude: float | None = Query(default=None),
    longitude: float | None = Query(default=None),
    category_id: int | None = Query(default=None),
    open_now: bool | None = Query(default=None),
) -> list[dict]:
    shops = load_shops(db)

    if category_id is not None:
        shops = [shop for shop in shops if shop.category_id == category_id]

    shops = filter_shops_by_location(shops, latitude, longitude)

    now = datetime.now()
    summaries = [build_shop_summary(shop, now) for shop in shops]

    if open_now is True:
        summaries = [summary for summary in summaries if summary["is_open_now"]]
    elif open_now is False:
        summaries = [summary for summary in summaries if not summary["is_open_now"]]

    return summaries


@router.post("", response_model=ShopDetailResponse, status_code=status.HTTP_201_CREATED)
def create_shop(
    payload: ShopCreateRequest,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_shop_user)],
) -> Shop:
    existing = db.query(Shop).filter(Shop.owner_user_id == current_user.id).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Shop already registered")

    shop = Shop(owner_user_id=current_user.id, **payload.model_dump())
    db.add(shop)
    db.commit()
    shop = (
        db.query(Shop)
        .options(
            joinedload(Shop.category),
            joinedload(Shop.images),
            joinedload(Shop.menus),
        )
        .filter(Shop.id == shop.id)
        .one()
    )
    return shop


@router.get("/{shop_id}", response_model=ShopDetailResponse)
def get_shop(shop_id: int, db: Annotated[Session, Depends(get_db)]) -> Shop:
    shop = (
        db.query(Shop)
        .options(
            joinedload(Shop.category),
            joinedload(Shop.images),
            joinedload(Shop.menus),
        )
        .filter(Shop.id == shop_id, Shop.is_published.is_(True))
        .first()
    )
    if shop is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shop not found")
    return shop
