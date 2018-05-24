import pandas as pd
from robinho.classifiers.base import BaseClassifier
from sklearn.naive_bayes import MultinomialNB
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from sklearn.preprocessing import FunctionTransformer
from robinho.marisa_vectorizers import MarisaTfidfVectorizer


class ClickBait(BaseClassifier):
    name = "click_bait"

    def filter(self, df):
        return df['title'].str.len() > 10

    def build_dataframe(self):
        df = self.load_links()
        df = df[df["clickbait_title"] != ""]

        extra_cb_titles = self.extra_clickbait_titles()
        df = df.append(pd.DataFrame({
            "title": extra_cb_titles,
            "clickbait_title": [1.0] * len(extra_cb_titles)
        }), ignore_index=True)

        extra_ncb_titles = self.extra_non_clickbait_titles()
        df = df.append(pd.DataFrame({
            "title": extra_ncb_titles,
            "clickbait_title": [0.0] * len(extra_ncb_titles)
        }), ignore_index=True)

        df["is_click_bait"] = [
            clickbait_title == 1.0
            for clickbait_title in df["clickbait_title"]
        ]

        return df

    def extra_clickbait_titles(self):
        extra1 = pd.read_csv("train_data/buzzfeedbr/clickbait_titles.csv")
        extra2 = pd.read_csv("train_data/bhargaviparanjape/clickbait_data.csv",
                             sep="\n", header=None)

        return extra1["title"].append(extra2[0])

    def extra_non_clickbait_titles(self):
        extra1 = pd.read_csv("train_data/buzzfeedbr/non_clickbait_titles.csv")
        extra2 = pd.read_csv("train_data/bhargaviparanjape/non_clickbait_data.csv",
                             sep="\n", header=None)

        return extra1["title"].append(extra2[0])

    def features_labels(self):
        df = self.build_dataframe()

        X = df[["title"]]
        y = df["is_click_bait"]

        return self.undersample_data(X, y)

    def classifier(self):
        return Pipeline([
            ('selector', FunctionTransformer(self.extract_title, validate=False)),
            ('tfidf', MarisaTfidfVectorizer(
                strip_accents='ascii', ngram_range=(1, 3), max_df=0.5, min_df=3)),
            ('sampling', RandomUnderSampler(random_state=BaseClassifier.RANDOM_SEED)),
            ('clf', MultinomialNB(fit_prior=False)),
        ])
