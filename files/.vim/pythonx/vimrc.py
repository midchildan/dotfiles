from datetime import datetime, timezone

def now():
	return datetime.now(tz=timezone.utc).isoformat(timespec='seconds')
