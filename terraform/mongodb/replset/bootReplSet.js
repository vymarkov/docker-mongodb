var status = rs.status();
if (!status.ok && status.code === 94) {
  rs.initiate({
    _id: "rs0",
    version: 1,
    members: [{
      _id: 0,
      host: "${primary_addr}:${port}"
    }]
  });

  sleep(5000);
}

{
  "${secondary_members_addr}".split(",").forEach(function (addr) {
    {
      res = rs.add(addr + ":${port}");
      if (!res.ok) {
        print(res.errmsg);
      }
    }
  });
}

{
  "${arbiter_addr}".split(",").forEach(function (addr) {
    result = rs.addArb(addr + ":${port}");
    if (!result.ok) {
      print(res.errmsg);
    }
  });
}

{
  "${hidden_members}".split(",").forEach(function (addr) {
    rs.add({
      host: addr + ":${port}",
      priority: 0,
      hidden: true
    });
    sleep(1000);
  });
}

{
  "${delayed_members}".split(",").forEach(function (addr) {
    rs.add({
      host: addr + ":${port}",
      slaveDelay: ${slaveDelay},
      priority: 0,
      hidden: true
    });
    sleep(1000);
  });
}
