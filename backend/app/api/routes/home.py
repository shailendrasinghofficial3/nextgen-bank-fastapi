from fastapi import APIRouter
from backend.app.core.logging import get_logger
logger = get_logger()
router  =APIRouter(prefix="/home")


@router.get("/")
def home():
    logger.info("Home Page accessed")
    logger.debug("Home Page accessed")
    logger.error("Home Page accessed")
    logger.warning("Home Page accessed")
    logger.critical("Home Page accessed")
    return {"message":"Our home get api"}