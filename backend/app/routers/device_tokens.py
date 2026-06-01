from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.auth.security import get_current_user
from app.database import get_db
from app.models import User
from app.schemas import DeviceTokenCreateRequest
from app.services.notifications import upsert_device_token

router = APIRouter(prefix="/device-tokens", tags=["device-tokens"])


@router.post("", status_code=status.HTTP_201_CREATED)
def register_device_token(
    payload: DeviceTokenCreateRequest,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> dict:
    token = upsert_device_token(db, current_user, payload.fcm_token, payload.platform)
    return {"id": token.id, "fcm_token": token.fcm_token, "platform": token.platform}
