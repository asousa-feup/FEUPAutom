
////////////////////////////////////////////////////////////
// FEUPAutom _ C _ v3.9 - 
// Code Automatically Generated:04/07/2014 17:36:05
////////////////////////////////////////////////////////////

//######################################//
//################ Page 3 ##############//
//######################################//

////////////////////////////////////////////////////////////
///////////// if( boot ==> Set Initial Steps /////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// Calc Fired Transitions ///////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// ReSet Steps Above fired Tr ///////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// Set Steps below fired Tr /////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
////////// Unset all Outputs (once for all pages) //////////
////////////////////////////////////////////////////////////

  _outbits[0]=0;
  _outbits[1]=0;
  _outbits[2]=0;
  _outbits[3]=0;
  _outbits[4]=0;
  _outbits[5]=0;
  _outbits[6]=0;
  _outbits[7]=0;
  _outbits[8]=0;
  _outbits[9]=0;
  _outbits[10]=0;
  _outbits[11]=0;
  _outbits[12]=0;
  _outbits[13]=0;
  _outbits[14]=0;
  _outbits[15]=0;
  _outbits[16]=0;
  _outbits[17]=0;
  _outbits[18]=0;
  _outbits[19]=0;
  _outbits[20]=0;
  _outbits[21]=0;
  _outbits[22]=0;
  _outbits[23]=0;
  _outbits[24]=0;
  _outbits[25]=0;
  _outbits[26]=0;
  _outbits[27]=0;
  _outbits[28]=0;
  _outbits[29]=0;
  _outbits[30]=0;
  _outbits[31]=0;
  _outbits[32]=0;
  _outbits[33]=0;
  _outbits[34]=0;
  _outbits[35]=0;
  _outbits[36]=0;
  _outbits[37]=0;
  _outbits[38]=0;
  _outbits[39]=0;
  _outbits[40]=0;
  _outbits[41]=0;
  _outbits[42]=0;
  _outbits[43]=0;
  _outbits[44]=0;
  _outbits[45]=0;
  _outbits[46]=0;
  _outbits[47]=0;

////////////////////////////////////////////////////////////
///// if( step active increment MW timer of step @ _sysbits[16] /////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
//////// if( step active, execute its action code ///////////
////////////////////////////////////////////////////////////


//######################################//
//################ Page 2 ##############//
//######################################//

////////////////////////////////////////////////////////////
///////////// if( boot ==> Set Initial Steps /////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// Calc Fired Transitions ///////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// ReSet Steps Above fired Tr ///////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// Set Steps below fired Tr /////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///// if( step active increment MW timer of step @ _sysbits[16] /////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
//////// if( step active, execute its action code ///////////
////////////////////////////////////////////////////////////


//######################################//
//################ Page 1 ##############//
//######################################//

////////////////////////////////////////////////////////////
///////////// if( boot ==> Set Initial Steps /////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// Calc Fired Transitions ///////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// ReSet Steps Above fired Tr ///////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///////////////// Set Steps below fired Tr /////////////////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
///// if( step active increment MW timer of step @ _sysbits[16] /////
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
//////// if( step active, execute its action code ///////////
////////////////////////////////////////////////////////////


//######################################//
//################ Page 0 ##############//
//######################################//

////////////////////////////////////////////////////////////
///////////// if( boot ==> Set Initial Steps /////////////////
////////////////////////////////////////////////////////////

  // ObjIdx==0 ==> INI_Step "_membits[0]"
  if( (_syswords[0]==0) ) {
    _membits[0] = 1;
  };

////////////////////////////////////////////////////////////
///////////////// Calc Fired Transitions ///////////////////
////////////////////////////////////////////////////////////

// ObjIdx==1 ==> Transition "_membits[1]"
  // Steps Above: id==0 ==> _membits[0] ;
  // Steps Below: id==2 ==> _membits[2] ;
  _membits[1] =  _membits[0] &&  ((_memwords[0]>5) || _InBitsFunc[1]()) ;
// ObjIdx==3 ==> Transition "_membits[3]"
  // Steps Above: id==2 ==> _membits[2] ;
  // Steps Below: id==0 ==> _membits[0] ;
  _membits[3] =  _membits[2] &&  ((_memwords[2]>5) || _InBitsFunc[2]()) ;

////////////////////////////////////////////////////////////
///////////////// ReSet Steps Above fired Tr ///////////////
////////////////////////////////////////////////////////////

// ObjIdx==1 ==> Transition "_membits[1]"
  // Steps Above: id==0 ==> _membits[0] ;
  // Steps Below: id==2 ==> _membits[2] ;
  if( (_membits[1]) ) {
     _membits[0]=0; 
  };
// ObjIdx==3 ==> Transition "_membits[3]"
  // Steps Above: id==2 ==> _membits[2] ;
  // Steps Below: id==0 ==> _membits[0] ;
  if( (_membits[3]) ) {
     _membits[2]=0; 
  };

////////////////////////////////////////////////////////////
///////////////// Set Steps below fired Tr /////////////////
////////////////////////////////////////////////////////////

// ObjIdx==1 ==> Transition "_membits[1]"
  // Steps Above: id==0 ==> _membits[0] ;
  // Steps Below: id==2 ==> _membits[2] ;
  if( (_membits[1]) ) { 
    _membits[2] = 1; 
    _memwords[2] = 0; 
  };
// ObjIdx==3 ==> Transition "_membits[3]"
  // Steps Above: id==2 ==> _membits[2] ;
  // Steps Below: id==0 ==> _membits[0] ;
  if( (_membits[3]) ) { 
    _membits[0] = 1; 
    _memwords[0] = 0; 
  };

////////////////////////////////////////////////////////////
///// if( step active increment MW timer of step @ _sysbits[16] /////
////////////////////////////////////////////////////////////

  // ObjIdx==0 ==> Step "_membits[0]"
  if( (_sysbits[16]) && (_membits[0]) ) { _memwords[0] = _memwords[0]+1; };
  // ObjIdx==2 ==> Step "_membits[2]"
  if( (_sysbits[16]) && (_membits[2]) ) { _memwords[2] = _memwords[2]+1; };

////////////////////////////////////////////////////////////
//////// if( step active, execute its action code ///////////
////////////////////////////////////////////////////////////

  // ObjIdx==0 ==> Step "_membits[0]" (code...)
  if( _membits[0] ) { 
    _memwords[100]=_memwords[100]+1;
    play("c32");
    while(is_playing());

  };
  // ObjIdx==2 ==> Step "_membits[2]" (code...)
  if( _membits[2] ) { 
    _memwords[101]=_memwords[101]+1;
    play("c32");
	while(is_playing());
  };

  _outbits[0]=_membits[0];
  _outbits[1]=_membits[0];
  
/*************** } of ST Code ****************/