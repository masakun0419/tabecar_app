from fastapi import FastAPI

from app.routers import auth, device_tokens, events, favorites, notifications, shops

app = FastAPI(title="食べカー API", version="1.0.0")

app.include_router(auth.router, prefix="/api/v1")
app.include_router(shops.router, prefix="/api/v1")
app.include_router(events.router, prefix="/api/v1")
app.include_router(favorites.router, prefix="/api/v1")
app.include_router(device_tokens.router, prefix="/api/v1")
app.include_router(notifications.router, prefix="/api/v1")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
