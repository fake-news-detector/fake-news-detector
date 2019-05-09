import numpy as np
from robinho.classifiers.base import BaseClassifier
from robinho.marisa_vectorizers import MarisaTfidfVectorizer
from nltk.corpus import stopwords
import pandas as pd
import unidecode

AMOUNT_OF_KEYWORDS = 8


class Keywords(BaseClassifier):
    name = "keywords"

    def features(self):
        df = self.load_links()

        return df["title_content"].values.tolist()

    def train(self):
        X = self.features()

        clf = self.classifier()
        clf.fit_transform(X)

        self.save_model(clf)

    def classifier(self):
        all_stopwords = list(map(unidecode.unidecode,
                                 stopwords.words('english') +
                                 stopwords.words('portuguese') +
                                 stopwords.words('spanish')
                                 ))

        return MarisaTfidfVectorizer(
            strip_accents='ascii',
            ngram_range=(1, 3),
            max_df=0.1,
            min_df=2,
            use_idf=True,
            lowercase=True,
            stop_words=all_stopwords)

    def find_keywords(self, title, content, url):
        text = title + content
        response = self.clf.transform([text])
        feature_array = np.array(self.clf.get_feature_names())

        response_arr = response.toarray()
        valid_words = [word for word in response_arr[0] if word > 0.0]

        df = pd.DataFrame()
        df['content'] = [text]
        df['url'] = [url]
        if not self.filter(df).bool():
            return []

        if len(valid_words) < AMOUNT_OF_KEYWORDS:
            return []

        tfidf_sorting = np.argsort(response_arr).flatten()[::-1]

        return feature_array[tfidf_sorting][:AMOUNT_OF_KEYWORDS].tolist()
