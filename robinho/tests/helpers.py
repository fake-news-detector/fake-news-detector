from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, recall_score
import pandas as pd


def test_once(X, y, clf, random_state=123):
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, random_state=random_state)

    clf = clf.fit(X_train, y_train)

    accuracy = clf.score(X_test, y_test)

    y_pred = clf.predict(X_test)
    avg_f1 = (
        f1_score(y_test, y_pred, pos_label=False) + f1_score(y_test, y_pred)
    ) / 2
    positive_recall = recall_score(y_test, y_pred)

    return accuracy, avg_f1, positive_recall


def test_multiple(X, y, clf, times):
    total_accuracy = 0
    total_f1 = 0
    total_positive_recall = 0

    for i in range(0, times):
        accuracy, f1, positive_recall = test_once(X, y, clf, random_state=i)
        total_accuracy += accuracy
        total_f1 += f1
        total_positive_recall += positive_recall

    return total_accuracy / times, total_f1 / times, total_positive_recall / times


def test_scores_snapshot(self, name, model, times=3):
    X, y = model.features_labels()

    accuracy, f1, positive_recall = test_multiple(
        X, y, model.classifier(), times)

    print("\n==", name, "==")
    print(pd.DataFrame({
        "Accur": [str(accuracy)[0:4]],
        "F1": [str(f1)[0:4]],
        "Recall": [str(positive_recall)[0:4]]
    }))

    return accuracy, f1, positive_recall
