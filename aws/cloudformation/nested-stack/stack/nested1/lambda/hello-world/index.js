function handler(event, context, callback) {
  console.log(
    "Event: ",
    JSON.stringify(event, null, 3)
  );

  callback(
    null,
    {
      message: "Ok"
    }
  );
}

exports.handler = handler;
