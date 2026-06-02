from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.auth.security import get_current_user
from app.database import get_db
from app.models import User, UserProfile
from app.schemas import ProfileResponse, ProfileUpdateRequest
from app.services.notifications import ensure_user_profile

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("", response_model=ProfileResponse)
def get_profile(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> UserProfile:
    return ensure_user_profile(db, current_user)


@router.patch("", response_model=ProfileResponse)
def update_profile(
    payload: ProfileUpdateRequest,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> UserProfile:
    profile = ensure_user_profile(db, current_user)

    if payload.latitude is not None:
        profile.last_latitude = payload.latitude
    if payload.longitude is not None:
        profile.last_longitude = payload.longitude
    if payload.notification_radius_km is not None:
        profile.notification_radius_km = payload.notification_radius_km

    db.commit()
    db.refresh(profile)
    return profile
