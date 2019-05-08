import pandas as pd
import pickle
from imblearn.under_sampling import RandomUnderSampler
from robinho.utils import current_ram
from whatthelang import WhatTheLang

loaded_models = {}
loaded_df = None


class BaseClassifier():
    RANDOM_SEED = 123

    def __init__(self):
        global loaded_models
        filepath = 'output/' + self.name + '.pkl'
        try:
            if filepath not in loaded_models:
                with open(filepath, "rb") as f:
                    loaded_models[filepath] = pickle.load(f)
                print("Loaded", filepath, "using", current_ram(), "of RAM")

            self.clf = loaded_models[filepath]
        except FileNotFoundError:
            self.train()

    def features_labels(self):
        raise NotImplementedError

    def undersample_data(self, X, y):
        columns = X.columns.values.tolist()

        X, y = RandomUnderSampler(random_state=BaseClassifier.RANDOM_SEED, sampling_strategy='all').fit_sample(
            X.values.tolist(), y.values.tolist())
        X = pd.DataFrame(X, columns=columns)

        return X, y

    def extract_title(self, X):
        return X['title']

    def extract_content(self, X):
        return X['content']

    def join_text_and_content(self, X):
        return X['title'] + ' ' + X['content']

    def classifier(self):
        raise NotImplementedError

    def filter(self, df):
        return (df['content'].str.len() > 120) & \
            (df['url'].str.contains(
                'youtube.com|youtu.be|twitter.com|vimeo.com|facebook.com') == False)  # NOQA

    def load_links(self):
        global loaded_df
        if loaded_df is not None:
            df = loaded_df
        else:
            try:
                df = pd.read_csv("train_data/links.csv")
            except FileNotFoundError:
                print("Downloading links data...")
                df = pd.read_json(
                    "https://api.fakenewsdetector.org/links/all")
                df.to_csv("train_data/links.csv")

            df.dropna(subset=["title", "content"], inplace=True, how="all")
            df["category_id"] = df['verified_category_id'].fillna(
                df['category_id'])

            df["clickbait_title"] = df['verified_clickbait_title'].fillna(
                df['clickbait_title'])

            df = df.fillna('')

            # Limiting
            df = df[0:5000]
            df["title_content"] = self.join_text_and_content(df)
            print("Detecting language and limiting links...")
            wtl = WhatTheLang()
            df["lang"] = [wtl.predict_lang(text[0:50]) for text in df["title_content"]]
            df = df[df["lang"] == 'en'][0:500].append(df[df["lang"] == 'es'][0:500]).append(df[df["lang"] == 'pt'][0:500])
            print(df[["title", "lang"]].groupby(['lang']).agg(['count']).T)

        loaded_df = df
        df = df.loc[self.filter]
        df = df.copy()

        return df

    def train(self):
        X, y = self.features_labels()

        clf = self.classifier()
        clf = clf.fit(X, y)

        self.save_model(clf)

    def save_model(self, clf):
        with open('output/' + self.name + '.pkl', "wb") as f:
            pickle.dump(clf, f)

        self.clf = clf

    def predict(self, title, content, url):
        df = pd.DataFrame()
        df['title'] = [title]
        df['content'] = [content]
        df['url'] = [url]
        if not self.filter(df).bool():
            return 0.0
        return self.clf.predict_proba(df)[0][1]
