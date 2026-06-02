from datetime import datetime
from decimal import Decimal
from enum import Enum

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserType(str, Enum):
    USER = "USER"
    SHOP = "SHOP"


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    display_name: str
    user_type: UserType


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str
    display_name: str
    user_type: str


class CategoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str


class MenuResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str | None
    price: int
    image_url: str | None
    is_available: bool
    display_order: int


class ShopImageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    image_url: str
    caption: str | None
    display_order: int


class ShopCreateRequest(BaseModel):
    category_id: int | None = None
    name: str = Field(max_length=120)
    description: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    website_url: str | None = None
    instagram_url: str | None = None
    x_url: str | None = None
    icon_image_url: str | None = None


class ShopSummaryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str | None
    icon_image_url: str | None
    category: CategoryResponse | None = None
    is_open_now: bool = False
    next_event_latitude: Decimal | None = None
    next_event_longitude: Decimal | None = None


class ShopDetailResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str | None
    phone: str | None
    email: str | None
    website_url: str | None
    instagram_url: str | None
    x_url: str | None
    icon_image_url: str | None
    category: CategoryResponse | None = None
    images: list[ShopImageResponse] = []
    menus: list[MenuResponse] = []


class EventCreateRequest(BaseModel):
    title: str = Field(max_length=120)
    address: str = Field(max_length=255)
    prefecture: str = Field(max_length=20)
    city: str | None = Field(default=None, max_length=80)
    latitude: Decimal
    longitude: Decimal
    start_at: datetime
    end_at: datetime
    note: str | None = None


class EventResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    shop_id: int
    shop_name: str
    title: str
    address: str
    prefecture: str
    city: str | None
    latitude: Decimal
    longitude: Decimal
    start_at: datetime
    end_at: datetime
    note: str | None
    is_cancelled: bool


class FavoriteCreateRequest(BaseModel):
    shop_id: int


class FavoriteResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    shop_id: int
    shop_name: str
    icon_image_url: str | None
    created_at: datetime


class DeviceTokenCreateRequest(BaseModel):
    fcm_token: str
    platform: str = "iOS"


class NotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    shop_id: int | None
    event_id: int | None
    notification_type: str
    title: str
    body: str
    is_read: bool
    created_at: datetime


class ProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    notification_radius_km: int
    last_latitude: Decimal | None
    last_longitude: Decimal | None


class ProfileUpdateRequest(BaseModel):
    latitude: Decimal | None = None
    longitude: Decimal | None = None
    notification_radius_km: int | None = Field(default=None, ge=1, le=100)


class UnreadCountResponse(BaseModel):
    count: int


class ReadAllNotificationsResponse(BaseModel):
    updated: int
