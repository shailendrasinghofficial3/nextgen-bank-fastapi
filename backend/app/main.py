from fastapi import FastAPI

app = FastAPI(title="Next Gen Bank", description="fully  features bank api")


@app.get("/")
def home():
    return {"message":"Our home get api"}