import math
from datetime import datetime
from decimal import Decimal

from sqlalchemy.orm import Session, joinedload

from app.models import Shop, ShopEvent


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    radius = 6371.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    d_phi = math.radians(lat2 - lat1)
    d_lambda = math.radians(lon2 - lon1)
    a = math.sin(d_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(d_lambda / 2) ** 2
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def get_active_event(shop: Shop, now: datetime) -> ShopEvent | None:
    for event in shop.events:
        if not event.is_cancelled and event.start_at <= now <= event.end_at:
            return event
    return None


def get_next_event(shop: Shop, now: datetime) -> ShopEvent | None:
    upcoming = [
        event
        for event in shop.events
        if not event.is_cancelled and event.end_at >= now
    ]
    if not upcoming:
        return None
    return min(upcoming, key=lambda event: event.start_at)


def load_shops(db: Session) -> list[Shop]:
    return (
        db.query(Shop)
        .options(
            joinedload(Shop.category),
            joinedload(Shop.events),
        )
        .filter(Shop.is_published.is_(True))
        .all()
    )


def filter_shops_by_location(
    shops: list[Shop],
    latitude: float | None,
    longitude: float | None,
    radius_km: float = 50.0,
) -> list[Shop]:
    if latitude is None or longitude is None:
        return shops

    filtered: list[Shop] = []
    for shop in shops:
        event = get_next_event(shop, datetime.now())
        if event is None:
            continue
        distance = haversine_km(
            latitude,
            longitude,
            float(event.latitude),
            float(event.longitude),
        )
        if distance <= radius_km:
            filtered.append(shop)
    return filtered


def build_shop_summary(shop: Shop, now: datetime | None = None) -> dict:
    now = now or datetime.now()
    active = get_active_event(shop, now)
    nxt = get_next_event(shop, now)
    target = active or nxt
    return {
        "id": shop.id,
        "name": shop.name,
        "description": shop.description,
        "icon_image_url": shop.icon_image_url,
        "category": shop.category,
        "is_open_now": active is not None,
        "next_event_latitude": target.latitude if target else None,
        "next_event_longitude": target.longitude if target else None,
    }


def load_events(db: Session) -> list[ShopEvent]:
    return (
        db.query(ShopEvent)
        .options(joinedload(ShopEvent.shop))
        .filter(ShopEvent.is_cancelled.is_(False))
        .order_by(ShopEvent.start_at.asc())
        .all()
    )


def filter_events_by_radius(
    events: list[ShopEvent],
    latitude: float,
    longitude: float,
    radius_km: int,
) -> list[ShopEvent]:
    return [
        event
        for event in events
        if haversine_km(latitude, longitude, float(event.latitude), float(event.longitude)) <= radius_km
    ]


def to_event_response(event: ShopEvent) -> dict:
    return {
        "id": event.id,
        "shop_id": event.shop_id,
        "shop_name": event.shop.name,
        "title": event.title,
        "address": event.address,
        "prefecture": event.prefecture,
        "city": event.city,
        "latitude": event.latitude,
        "longitude": event.longitude,
        "start_at": event.start_at,
        "end_at": event.end_at,
        "note": event.note,
        "is_cancelled": event.is_cancelled,
    }
