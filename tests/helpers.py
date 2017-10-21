from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, recall_score


def test_once(X, y, clf):
    X_train, X_test, y_train, y_test = train_test_split(X, y)

    clf = clf.fit(X_train, y_train)

    accuracy = clf.score(X_test, y_test)

    y_pred = clf.predict(X_test)
    avg_f1 = (
        f1_score(y_test, y_pred, pos_label=False) + f1_score(y_test, y_pred)
    ) / 2
    positive_recall = recall_score(y_test, y_pred)

    return accuracy, avg_f1, positive_recall


def test_multiple(X, y, clf):
    times = 50
    total_accuracy = 0
    total_f1 = 0
    total_positive_recall = 0

    for i in range(0, times):
        accuracy, f1, positive_recall = test_once(X, y, clf)
        total_accuracy += accuracy
        total_f1 += f1
        total_positive_recall += positive_recall

    return total_accuracy / times, total_f1 / times, total_positive_recall / times
