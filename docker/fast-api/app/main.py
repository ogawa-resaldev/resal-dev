from fastapi import FastAPI, Request
import os
import datetime

app = FastAPI()

@app.post('/api/add_rank_frames')
async def post_add_rank_frames(request: Request):
    response = {
        'message': 'api/add_rank_frames'
    }
    return response

@app.post('/api/reviews')
async def post_reviews(request: Request):
    response = {
        'message': 'api/reviews'
    }
    return response

@app.post('/api/therapists')
async def post_therapists(request: Request):
    response = {
        'message': 'api/therapists'
    }
    return response

@app.post('/line/oauth2/v3/token')
async def get_line_token(request: Request):
    response = {
        "token_type": "Bearer",
        "access_token": "dummy_access_token",
        "expires_in": 900
    }
    return response

@app.post('/line/v2/bot/message/push')
async def push_line_message(request: Request):
    body = await request.json()
    dir = "./line-messages/" + body["to"]
    if not os.path.exists(dir): # ディレクトリが存在するか確認
        os.makedirs(dir)
    f = open(dir + "/" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S"), "a")
    f.write(body["messages"][0]["text"])
    f.close()
    response = {
        "sentMessages": [
            {
                "id": "dummy",
                "quotoToken": "dummy",
            }
        ]
    }
    return response
