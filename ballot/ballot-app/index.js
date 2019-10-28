var express = require('express');
var app = express();
app.use(express.static('src'));
app.use(express.static('../ballot-contract/build/contracts'));


/*
const path = require('path');
const router = express.Router();

router.get('/',function(req,res){
  res.sendFile(path.join(__dirname+'/index.html'));
  //__dirname : It will resolve to your project folder.
});

router.get('/vote',function(req,res){
  res.sendFile(path.join(__dirname+'/vote.html'));
});


//add the router
app.use('/', router);
app.listen(process.env.port || 3000);

console.log('Running at Port 3000');
*/

app.get('/', function (req, res) {
  res.render('index.html');
});


app.listen(3000, function () {	 
  console.log('Example app listening on port 3000!');
});
