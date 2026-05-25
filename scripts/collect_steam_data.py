import requests
import pandas as pd
import time
from tqdm import tqdm
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"
RAW_DIR.mkdir(parents=True, exist_ok=True)

KAGGLE_FILE = RAW_DIR / "a_steam_data_2021_2025.csv"
OUTPUT_FILE = RAW_DIR / "steam_games_raw_5000.csv"


def get_app_list_from_kaggle(limit=5000):
    df = pd.read_csv(KAGGLE_FILE)

    if "appid" not in df.columns:
        raise ValueError("В Kaggle файле нет колонки appid")

    app_df = df[["appid", "name"]].dropna(subset=["appid"]).drop_duplicates(subset=["appid"])

    app_df["appid"] = app_df["appid"].astype(int)

    app_df = app_df.head(limit)

    app_df.to_csv(RAW_DIR / "steam_app_list_from_kaggle.csv", index=False)

    return app_df


def get_app_details(appid):
    url = f"https://store.steampowered.com/api/appdetails?appids={appid}&cc=us&l=en"
    response = requests.get(url, timeout=30)
    response.raise_for_status()

    data = response.json()
    app_data = data.get(str(appid), {})

    if not app_data.get("success"):
        return None

    return app_data.get("data", {})


def parse_game_data(appid, data):
    price = data.get("price_overview", {})

    return {
        "appid": appid,
        "name": data.get("name"),
        "type": data.get("type"),
        "is_free": data.get("is_free"),
        "release_date": data.get("release_date", {}).get("date"),
        "developers": ", ".join(data.get("developers", [])) if data.get("developers") else None,
        "publishers": ", ".join(data.get("publishers", [])) if data.get("publishers") else None,
        "genres": ", ".join([g.get("description", "") for g in data.get("genres", [])]) if data.get("genres") else None,
        "categories": ", ".join([c.get("description", "") for c in data.get("categories", [])]) if data.get("categories") else None,
        "platform_windows": data.get("platforms", {}).get("windows"),
        "platform_mac": data.get("platforms", {}).get("mac"),
        "platform_linux": data.get("platforms", {}).get("linux"),
        "required_age": data.get("required_age"),
        "metacritic_score": data.get("metacritic", {}).get("score"),
        "recommendations": data.get("recommendations", {}).get("total"),
        "price_currency": price.get("currency"),
        "initial_price": price.get("initial"),
        "final_price": price.get("final"),
        "discount_percent": price.get("discount_percent"),
    }


def collect_games(limit=5000, sleep_time=0.5):
    app_df = get_app_list_from_kaggle(limit=limit)

    results = []

    for appid in tqdm(app_df["appid"], total=len(app_df)):
        try:
            data = get_app_details(appid)

            if data:
                parsed = parse_game_data(appid, data)
                results.append(parsed)

            time.sleep(sleep_time)

        except Exception as e:
            print(f"Error with appid {appid}: {e}")
            time.sleep(2)

    games_df = pd.DataFrame(results)
    games_df.to_csv(OUTPUT_FILE, index=False)

    print("Saved:", OUTPUT_FILE)
    print("Rows:", len(games_df))
    print(games_df.head())


if __name__ == "__main__":
    collect_games(limit=15000, sleep_time=0.5)