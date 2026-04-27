import re
from collections import defaultdict
from pathlib import Path

p = Path(r"c:\\Users\\sumit\\Downloads\\Dora\\flutter_debug_v2.txt")
lines = p.read_text(encoding='utf-8', errors='ignore').splitlines()

req_pat = re.compile(r"uri:\s+(https?://\S+)")
status_pat = re.compile(r"statusCode:\s+(\d+)")
method_pat = re.compile(r"method:\s+(\w+)")

records = []
cur = None
phase = None
for i,l in enumerate(lines, start=1):
    if '*** Request ***' in l:
        cur = {'line': i, 'type':'request', 'uri':None, 'method':None}
        phase='req'
        continue
    if '*** Response ***' in l:
        cur = {'line': i, 'type':'response', 'uri':None, 'status':None}
        phase='res'
        continue
    if '*** DioException ***' in l:
        cur = {'line': i, 'type':'dio', 'uri':None, 'status':None}
        phase='dio'
        continue
    if cur is None:
        continue

    m = req_pat.search(l)
    if m:
        cur['uri'] = m.group(1)
    mm = method_pat.search(l)
    if mm:
        cur['method'] = mm.group(1)
    ms = status_pat.search(l)
    if ms:
        cur['status'] = int(ms.group(1))

    # finalize when enough data
    if cur['type']=='request' and cur.get('uri') and cur.get('method'):
        records.append(cur); cur=None; phase=None
    elif cur['type']=='response' and cur.get('uri') and cur.get('status') is not None:
        records.append(cur); cur=None; phase=None
    elif cur['type']=='dio' and cur.get('uri'):
        records.append(cur); cur=None; phase=None

# summarize endpoint paths
from urllib.parse import urlparse

req_counts = defaultdict(int)
res_counts = defaultdict(lambda: defaultdict(int))
dio_counts = defaultdict(int)

for r in records:
    uri = r.get('uri')
    if not uri:
        continue
    path = urlparse(uri).path
    if r['type']=='request':
        req_counts[(r.get('method','?'), path)] += 1
    elif r['type']=='response':
        res_counts[path][r.get('status')] += 1
    elif r['type']=='dio':
        dio_counts[path] += 1

print('REQUEST_COUNTS')
for (m,path),c in sorted(req_counts.items(), key=lambda x:(x[0][1],x[0][0])):
    if '/api/v1/' in path:
        print(f"{c:3d} {m:6s} {path}")

print('\nRESPONSE_STATUS_COUNTS')
for path,stats in sorted(res_counts.items()):
    if '/api/v1/' in path:
        s = ', '.join([f"{k}:{v}" for k,v in sorted(stats.items())])
        print(f"{path} -> {s}")

print('\nDIO_EXCEPTIONS')
for path,c in sorted(dio_counts.items()):
    if '/api/v1/' in path:
        print(f"{c:3d} {path}")
