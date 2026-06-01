from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload

from app.auth.security import require_shop_user
from app.database import get_db
from app.models import Shop, ShopEvent, User
from app.schemas import EventCreateRequest, EventResponse
from app.services.geo import filter_events_by_radius, load_events, to_event_response
from app.services.notifications import notify_favorite_users, notify_nearby_users

router = APIRouter(prefix="/events", tags=["events"])


@router.get("", response_model=list[EventResponse])
def list_events(
    db: Annotated[Session, Depends(get_db)],
    latitude: float | None = Query(default=None),
    longitude: float | None = Query(default=None),
    radius_km: int = Query(default=5, ge=1),
) -> list[dict]:
    events = load_events(db)

    if latitude is not None and longitude is not None:
        events = filter_events_by_radius(events, latitude, longitude, radius_km)

    return [to_event_response(event) for event in events]


@router.post("", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
def create_event(
    payload: EventCreateRequest,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_shop_user)],
) -> dict:
    if payload.end_at <= payload.start_at:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="end_at must be after start_at")

    shop = db.query(Shop).filter(Shop.owner_user_id == current_user.id).first()
    if shop is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shop not found for current user")

    event = ShopEvent(shop_id=shop.id, **payload.model_dump())
    db.add(event)
    db.commit()
    db.refresh(event)

    event = (
        db.query(ShopEvent)
        .options(joinedload(ShopEvent.shop))
        .filter(ShopEvent.id == event.id)
        .one()
    )

    notify_favorite_users(db, event)
    notify_nearby_users(db, event)

    return to_event_response(event)
