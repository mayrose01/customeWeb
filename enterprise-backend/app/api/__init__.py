from fastapi import APIRouter
from .endpoints import company, category, product, inquiry, user, upload, carousel, contact_message, service, client_product, client_user

router = APIRouter()
router.include_router(company.router, prefix="/company", tags=["company"])
router.include_router(category.router, prefix="/category", tags=["category"])
router.include_router(product.router, prefix="/product", tags=["product"])
router.include_router(inquiry.router, prefix="/inquiry", tags=["inquiry"])
router.include_router(user.router, prefix="/user", tags=["user"])
router.include_router(upload.router, prefix="/upload", tags=["upload"])
router.include_router(carousel.router, prefix="/carousel", tags=["carousel"])
router.include_router(contact_message.router, prefix="/contact-message", tags=["contact-message"])
router.include_router(service.router, prefix="/service", tags=["service"])
router.include_router(client_product.router, prefix="/client-product", tags=["client-product"])
router.include_router(client_user.router, prefix="/client-user", tags=["client-user"]) 