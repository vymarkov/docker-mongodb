
// when you need to make some manipulations to the database without a third-party code, 
// use this script 

var admins = [{
 user: 'mark',
 pwd: 'mark',
 roles: [
   {
     role: 'dbOwner',
     db: 'dev'
   }
 ] 
}];

var dbs = ['staging', 'testing'];

// if script was successfully executed you can use, for example,
//  a command below to connect using credentials:   
//  mongo -u mark -p mark --authenticationDatabase admin --host mongo dev 

for (var i = 0; i < admins.length; i++) {
  try {
    for(var j = 0; j < dbs.length; j++) {
      admins[i].roles.push({
        role: 'dbOwner',
        db: dbs[j]
      });
    }
    db.createUser(admins[i]);
  } catch (e) {
    switch(e.code) {
      case 11000:
      print('user already exists');
      break;
    }
  }
}