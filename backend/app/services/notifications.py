from sqlalchemy.orm import Session

from app.models import DeviceToken, Notification, ShopEvent, User, UserProfile
from app.models import Favorite as FavoriteModel


def ensure_user_profile(db: Session, user: User) -> UserProfile:
    if user.profile is None:
        profile = UserProfile(user_id=user.id)
        db.add(profile)
        db.commit()
        db.refresh(user)
    return user.profile


def notify_favorite_users(db: Session, event: ShopEvent) -> None:
    favorites = (
        db.query(FavoriteModel)
        .filter(FavoriteModel.shop_id == event.shop_id)
        .all()
    )
    for favorite in favorites:
        notification = Notification(
            user_id=favorite.user_id,
            shop_id=event.shop_id,
            event_id=event.id,
            notification_type="FAVORITE_EVENT",
            title="お気に入り店舗が出店します",
            body=f"{event.shop.name}が{event.address}に出店予定です。",
        )
        db.add(notification)
    db.commit()


def notify_nearby_users(db: Session, event: ShopEvent, radius_km: int = 5) -> None:
    from app.services.geo import haversine_km

    profiles = db.query(UserProfile).filter(UserProfile.last_latitude.isnot(None)).all()
    for profile in profiles:
        distance = haversine_km(
            float(profile.last_latitude),
            float(profile.last_longitude),
            float(event.latitude),
            float(event.longitude),
        )
        if distance <= radius_km:
            notification = Notification(
                user_id=profile.user_id,
                shop_id=event.shop_id,
                event_id=event.id,
                notification_type="NEARBY_EVENT",
                title="近くにキッチンカーが出店します",
                body=f"{event.shop.name}が{event.address}に出店予定です。",
            )
            db.add(notification)
    db.commit()


def upsert_device_token(db: Session, user: User, fcm_token: str, platform: str) -> DeviceToken:
    existing = db.query(DeviceToken).filter(DeviceToken.fcm_token == fcm_token).first()
    if existing:
        existing.user_id = user.id
        existing.platform = platform
        existing.is_active = True
        db.commit()
        db.refresh(existing)
        return existing

    token = DeviceToken(user_id=user.id, fcm_token=fcm_token, platform=platform)
    db.add(token)
    db.commit()
    db.refresh(token)
    return token
