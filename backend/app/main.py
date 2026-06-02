import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, status
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from app.config import settings
from app.database import SessionLocal
from app.routers import auth, device_tokens, events, favorites, notifications, profile, shops

logger = logging.getLogger(__name__)


def check_db_connection() -> tuple[bool, str]:
    db = SessionLocal()
    try:
        db.execute(text("SELECT 1"))
        shop_count = db.execute(text("SELECT COUNT(*) FROM shops")).scalar_one()
        return True, f"connected (shops={shop_count})"
    except SQLAlchemyError as exc:
        return False, str(exc.__cause__ or exc)
    finally:
        db.close()


@asynccontextmanager
async def lifespan(_: FastAPI):
    ok, detail = check_db_connection()
    if ok:
        logger.info("Database ready: %s", detail)
    else:
        logger.error("Database unavailable: %s", detail)
    logger.info("DATABASE_URL host/db: %s", settings.database_url.rsplit("@", 1)[-1])
    yield


app = FastAPI(title="食べカー API", version="1.0.0", lifespan=lifespan)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(shops.router, prefix="/api/v1")
app.include_router(events.router, prefix="/api/v1")
app.include_router(favorites.router, prefix="/api/v1")
app.include_router(device_tokens.router, prefix="/api/v1")
app.include_router(notifications.router, prefix="/api/v1")
app.include_router(profile.router, prefix="/api/v1")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/health/db")
def health_db():
    ok, detail = check_db_connection()
    if ok:
        return {"status": "ok", "detail": detail}
    return JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"status": "error", "detail": detail},
    )
