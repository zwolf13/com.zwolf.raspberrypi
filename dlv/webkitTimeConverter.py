from datetime import datetime, timedelta

def date_from_webkit(webkit_timestamp):
    epoch_start = datetime(1601, 1, 1)
    delta = timedelta(microseconds=int(webkit_timestamp))
    return epoch_start + delta

def date_to_webkit(date_string):
    epoch_start = datetime(1601, 1, 1)
    date_ = datetime.strptime(date_string, '%Y-%m-%d %H:%M:%S')
    diff = date_ - epoch_start
    seconds_in_day = 60 * 60 * 24
    return '{:<017d}'.format(diff.days * seconds_in_day + diff.seconds + diff.microseconds)

# Webkit to date
print(date_from_webkit('13259602565930468'))

# Date string to Webkit timestamp
# date_to_webkit('2016-08-24 10:35:47')

