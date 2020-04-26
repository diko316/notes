function handler(event, context, callback) {
  console.log(
    "Event: ",
    JSON.stringify(event, null, 3)
  );

  console.log(
    "Package1: ",
    require("@test-layer/package1")
  );

  console.log(
    "Package2: ",
    require("@test-layer/package2")
  );

  callback(
    null,
    {
      message: "Ok"
    }
  );
}

exports.handler = handler;
