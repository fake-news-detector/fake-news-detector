import requests


def track_event(category, action, user_id, label=None, value=0):
    data = {
        'v': '1',  # API Version.
        'tid': 'UA-108055161-1',  # Tracking ID / Property ID.
        # Anonymous Client Identifier. Ideally, this should be a UUID that
        # is associated with particular user, device, or browser instance.
        'cid': user_id,
        't': 'event',  # Event hit type.
        'ec': category,  # Event category.
        'ea': action,  # Event action.
        'el': label,  # Event label.
        'ev': value,  # Event value, must be an integer
    }

    print("Tracking", category, action, "for", user_id)
    requests.post(
        'http://www.google-analytics.com/collect', data=data)
