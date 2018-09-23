//+------------------------------------------------------------------+
//|                                          InterModel(Ver 2.0).mq4 |
//|                               Copyright 2016, Natakorn Software. |
//|                                             job.masker@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Natakorn Software."
#property link      "job.masker@gmail.com"
#property version   "1.00"
#property strict

input int ID=627834; //Account Number
extern int Tarket_Profit=800;//Take Profit
extern int Stop_Loss=400; //Stop Loss
extern int Magicnumber=0000;
int ticket,Win,OrderTotal,Loss,ProfitFactor,Factor=100000,Step=0,Times=0,W;
double LotS,TotalLots;
string Accuracy;


//----------------------------------get indicator-----------------------------------
double Value1,Value2,Value1sh,Value2sh;
 void getCCI(){
   Value1=iCustom(Symbol(),60,"CCI_Histogram",45,0,1);
   Value2=iCustom(Symbol(),60,"CCI_Histogram",45,1,1);
   Value1sh=iCustom(Symbol(),60,"CCI_Histogram",45,0,2);
   Value2sh=iCustom(Symbol(),60,"CCI_Histogram",45,1,2);
      }
     
double AllProfit(){
    double Profit=0;
     for(int i=OrdersHistoryTotal()-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true){
       if(OrderSymbol()==Symbol()&&OrderMagicNumber()==Magicnumber){
        Profit=Profit+OrderProfit()+OrderCommission()+OrderSwap();
          }
         }
        }
    return(Profit);
     }
int FirstBalance(){
   int FirstBal=(int)(MathCeil((AccountBalance()-AllProfit()-AccountCredit())));
   return(FirstBal);
}
double FloorFirstBal(){
  int A=(int)(pow(10,StringLen((string)FirstBalance())-1));   
  double CalFirstBal=floor(FirstBalance()/A)*A;
  return(CalFirstBal);
}
void LotStand(){
    if(ProfitFactor==0){
        LotS=FloorFirstBal()/Factor;
        if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT);
        ProfitFactor++;
     }
    else if(AccountBalance()>(double)MarketInfo(Symbol(),MODE_MAXLOT)*Factor/10) LotS=(double)MarketInfo(Symbol(),MODE_MAXLOT)/10;   
    else if(AccountBalance()>=FirstBalance()*pow(2,ProfitFactor)){  
        LotS=LotS*2; 
        ProfitFactor++;
     }
    else if(AccountBalance()<FirstBalance()*pow(2,ProfitFactor))  LotS=LotS;
    }
void CountLotStep(){
      int a=0;
      Step=0; 
       int Range = 0;
       for(int n=OrdersHistoryTotal()-1;n>=0;n--){
        if(a>=4){
         break;}
         if(OrderSelect(n,SELECT_BY_POS,MODE_HISTORY)==true){
          if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){
           a++;
           if(OrderLots()==LotS){
            Range = (int)(fabs(TimeHour(TimeCurrent()) - TimeHour(OrderCloseTime()))) - 1;
            switch(OrderType()){
             case OP_BUY:
              if(High[Range]>=OrderTakeProfit()&&OrderTakeProfit()!=0){ 
                Step = Step;}
             else if(OrderClosePrice()<OrderTakeProfit()&&OrderTakeProfit()!=0){
                Step++;}
               break;
             case OP_SELL:
              if(Low[Range]<=OrderTakeProfit()&&OrderTakeProfit()!=0){
                Step = Step;}
             else if(OrderClosePrice()>OrderTakeProfit()&&OrderTakeProfit()!=0){
                Step++;}
               break;
              }
             }else{break;}
            }
           } 
          }   
         }
int CheckHis(){
   int History=0;
    for(int i=OrdersHistoryTotal()-1;i>=0;i--){
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
      if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){
         History++;
        }
       }
      } 
     return(History);
    }    
void CountStop(){
    Times=0;
    int Range = 0;
    for(int i=OrdersHistoryTotal()-1;i>=0;i--){
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true){
      if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){
       Range = (int)(fabs(TimeHour(TimeCurrent()) - TimeHour(OrderCloseTime()))) - 1;
       switch(OrderType()){
        case OP_BUY:
         if(High[Range] >= OrderTakeProfit()&&OrderTakeProfit()!=0) i=-1;
         else if(OrderClosePrice()<OrderTakeProfit()&&OrderTakeProfit()!=0){ 
               if(Times==11) {Times=0;}
                Times++;
          }
          break;
        case OP_SELL:
         if(Low[Range]<=OrderTakeProfit()&&OrderTakeProfit()!=0) i=-1;
         else if(OrderClosePrice()>OrderTakeProfit()&&OrderTakeProfit()!=0){ 
               if(Times==11) {Times=0;}
                Times++;
         }
          break;
            }
           }
          }
         }
        }
void CountWOL(){ 
    Win=0; OrderTotal=0; Loss=0; 
    int Range = 0;  
      for(int i=OrdersHistoryTotal()-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true){
       if(OrderSymbol()==Symbol()&&OrderMagicNumber()==Magicnumber){
          Range = (int)(fabs(TimeHour(TimeCurrent()) - TimeHour(OrderCloseTime()))) - 1;
          switch(OrderType()){
             case OP_BUY:
              if(High[Range]>=OrderTakeProfit()&&OrderTakeProfit()!=0){
                Win++;
                OrderTotal++;} 
              else if(OrderClosePrice()<OrderTakeProfit()&&OrderTakeProfit()!=0){
                Loss++;
                OrderTotal++;}
                break;
             case OP_SELL:
              if(Low[Range]<=OrderTakeProfit()&&OrderTakeProfit()!=0){
                Win++;
                OrderTotal++;}
              else if(OrderClosePrice()>OrderTakeProfit()&&OrderTakeProfit()!=0){
                Loss++;
                OrderTotal++;}
                break;
               }
              }
             }
            }
           }
void CalAccuracy(){
   double x;   
   double a=Win;
   double b=OrderTotal;    
       x=(a/b)*100;
       Accuracy=DoubleToStr(x,2);
       }
void CountLots(){
  TotalLots=0; 
   for(int i=OrdersHistoryTotal()-1;i>=0;i--){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true){
     if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){
      TotalLots=NormalizeDouble(TotalLots+OrderLots(),2);
      }
     }
    } 
   }      
void checkwin(){
 int a=0; W=0;
  int Range = 0; 
  for(int i=OrdersHistoryTotal()-1;i>=0;i--){
       if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){
         if(a==2) break;
         a++;
          Range = (int)(fabs(TimeHour(TimeCurrent()) - TimeHour(OrderCloseTime()))) - 1;
          switch(OrderType()){
             case OP_BUY:
              if(High[Range]>=OrderTakeProfit()&&OrderTakeProfit()!=0) {W++; break;}
               else{break;}
             case OP_SELL:
              if(Low[Range]<=OrderTakeProfit()&&OrderTakeProfit()!=0) {W++; break;}
               else{break;}
               }
              }
             }
            }
           }                  
void openbuy(){
   LotStand();  
   CountLotStep();
   checkwin();
   CountStop();
   double Sl,Tp,Lot=LotS;
   Sl=Ask-Stop_Loss*Point;
   Tp=Ask+Tarket_Profit*Point;
     if(CheckHis()!=0){
      for(int i=OrdersHistoryTotal()-1;i>=0;i--){
       if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){ 
           i=-1;
          if(Times==11) Lot=LotS;
         else if(W==0){
           if(Step==0||Step==2) Lot=OrderLots()+LotS;
           if(Step==1) Lot=LotS;}
         else if(W!=0) {Lot=LotS;}
              }
             }
            }
           }   
       else{ Lot=LotS;}
               do{ticket=OrderSend(Symbol(),OP_BUY,Lot,Ask,5,Sl,Tp,"BUY",Magicnumber,0,clrBlue);
                if(OrdersTotal() == 1) Tp=0;
              }while(OrdersTotal()<2);
             }
               
void opensell(){
   LotStand(); 
   CountLotStep();
   checkwin();
   CountStop();
   double Sl,Tp,Lot=LotS;
   Sl=Bid+Stop_Loss*Point;
   Tp=Bid-Tarket_Profit*Point;  
     if(CheckHis()!=0){
      for(int i=OrdersHistoryTotal()-1;i>=0;i--){
       if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        if(OrderMagicNumber()==Magicnumber&&OrderSymbol()==Symbol()){ 
           i=-1;
         if(Times==11) Lot=LotS;
          else if(W==0){
           if(Step==0||Step==2) Lot=OrderLots()+LotS;
           if(Step==1)  Lot=LotS;}
          else if(W!=0){ Lot=LotS;}
             }
            } 
           } 
         }else{Lot=LotS;}
               do{ticket=OrderSend(Symbol(),OP_SELL,Lot,Bid,5,Sl,Tp,"Sell",Magicnumber,0,clrRed);
                if(OrdersTotal() == 1) Tp=0;
              }while(OrdersTotal()<2);
             }    
void CloseOrder(int type){
     for(int i=OrdersTotal()-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS)==true){
       if(OrderType()==type&&OrderSymbol()==Symbol()){
        if(OrderMagicNumber()==Magicnumber){
         switch (type){
            case OP_BUY:
                if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_BID),5,clrNONE)==true){
                  break;}
            case OP_SELL:
                if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_ASK),5,clrNONE)==true){
                  break;}
                }
               }
              } 
             }
            }
           }     
void CloseOrderEnd(){
     for(int i=OrdersTotal()-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS)==true){
       if(OrderSymbol()==Symbol()){
        if(OrderMagicNumber()==Magicnumber){
         switch (OrderType()){
            case OP_BUY:
                if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_BID),5,clrNONE)==true){
                  break;}
            case OP_SELL:
                if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(Symbol(),MODE_ASK),5,clrNONE)==true){
                  break;}
                }
               }
              } 
             }
            }
           }  
int CountOrderAll(){
      int Cnt=0;
        for(int i=0;i<OrdersTotal();i++){
          if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderSymbol()==Symbol()){
              if(OrderMagicNumber()==Magicnumber){
                Cnt++;}}}}
        return (Cnt);
        }    
//------------------------------------Create Button(Clear)--------------------------------------
void CreateClear(){
        ObjectCreate(0,"Clear",OBJ_BUTTON,0,0,0);
        ObjectSetInteger(0,"Clear",OBJPROP_XDISTANCE,10);
        ObjectSetInteger(0,"Clear",OBJPROP_YDISTANCE,30);
        ObjectSetInteger(0,"Clear",OBJPROP_XSIZE,60);
        ObjectSetInteger(0,"Clear",OBJPROP_YSIZE,20); 
        ObjectSetString(0,"Clear",OBJPROP_TEXT,"Clear"); 
        ObjectSetInteger(0,"Clear",OBJPROP_FONTSIZE,10);
        ObjectSetInteger(0,"Clear",OBJPROP_BGCOLOR,clrOrange);
        ObjectSetInteger(0,"Clear",OBJPROP_COLOR,clrWhite);
        ObjectSetInteger(0,"Clear",OBJPROP_CORNER,CORNER_LEFT_LOWER); 
        }  
//---------------------------------------Object Create(Information)---------------------------------------------
void CreateObjectCon1(){
     ObjectCreate(0,"Model",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"Model",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"Model",OBJPROP_XDISTANCE,105);
     ObjectSetInteger(0,"Model",OBJPROP_YDISTANCE,15);
     ObjectSetString(0,"Model",OBJPROP_TEXT,"Inter Model 2.0");
     ObjectSetInteger(0,"Model",OBJPROP_FONTSIZE,15);
     ObjectSetInteger(0,"Model",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"Model",OBJPROP_BACK,false);
    
     ObjectCreate(0,"Account",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"Account",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"Account",OBJPROP_XDISTANCE,9);
     ObjectSetInteger(0,"Account",OBJPROP_YDISTANCE,39);
     ObjectSetString(0,"Account",OBJPROP_TEXT,"Account Name:"+AccountName());
     ObjectSetInteger(0,"Account",OBJPROP_FONTSIZE,12);
     ObjectSetInteger(0,"Account",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"Account",OBJPROP_BACK,false);
     
     ObjectCreate(0,"Company",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"Company",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
     ObjectSetInteger(0,"Company",OBJPROP_XDISTANCE,355);
     ObjectSetInteger(0,"Company",OBJPROP_YDISTANCE,50);
     ObjectSetString(0,"Company",OBJPROP_TEXT,"Natakorn Software");
     ObjectSetInteger(0,"Company",OBJPROP_FONTSIZE,25);
     ObjectSetInteger(0,"Company",OBJPROP_COLOR,clrRed);
   }
     
//-----------------------------------Object Create2-------------------------------------
void CreateObjectCon2(){
     ObjectCreate(0,"TotalSig",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"TotalSig",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"TotalSig",OBJPROP_XDISTANCE,9);
     ObjectSetInteger(0,"TotalSig",OBJPROP_YDISTANCE,64);
     ObjectSetString(0,"TotalSig",OBJPROP_TEXT,"Total Signals=");
     ObjectSetInteger(0,"TotalSig",OBJPROP_FONTSIZE,12);
     ObjectSetInteger(0,"TotalSig",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"TotalSig",OBJPROP_BACK,false);
     
     ObjectCreate(0,"CountWin",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"CountWin",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"CountWin",OBJPROP_XDISTANCE,9);
     ObjectSetInteger(0,"CountWin",OBJPROP_YDISTANCE,114);
     ObjectSetString(0,"CountWin",OBJPROP_TEXT,"Win=");
     ObjectSetInteger(0,"CountWin",OBJPROP_FONTSIZE,12);
     ObjectSetInteger(0,"CountWin",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"CountWin",OBJPROP_BACK,false);
     
     ObjectCreate(0,"CountLoss",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"CountLoss",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"CountLoss",OBJPROP_XDISTANCE,9);
     ObjectSetInteger(0,"CountLoss",OBJPROP_YDISTANCE,139);
     ObjectSetString(0,"CountLoss",OBJPROP_TEXT,"Loss=");
     ObjectSetInteger(0,"CountLoss",OBJPROP_FONTSIZE,12);
     ObjectSetInteger(0,"CountLoss",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"CountLoss",OBJPROP_BACK,false);
     
     ObjectCreate(0,"Percent Accuracy",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"Percent Accuracy",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"Percent Accuracy",OBJPROP_XDISTANCE,9);
     ObjectSetInteger(0,"Percent Accuracy",OBJPROP_YDISTANCE,164);
     ObjectSetString(0,"Percent Accuracy",OBJPROP_TEXT,"Accuracy=");
     ObjectSetInteger(0,"Percent Accuracy",OBJPROP_FONTSIZE,12);
     ObjectSetInteger(0,"Percent Accuracy",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"Percent Accuracy",OBJPROP_BACK,false);
     
     ObjectCreate(0,"TotalLots",OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,"TotalLots",OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,"TotalLots",OBJPROP_XDISTANCE,9);
     ObjectSetInteger(0,"TotalLots",OBJPROP_YDISTANCE,89);
     ObjectSetString(0,"TotalLots",OBJPROP_TEXT,"TotalLots=");
     ObjectSetInteger(0,"TotalLots",OBJPROP_FONTSIZE,12);
     ObjectSetInteger(0,"TotalLots",OBJPROP_COLOR,clrGold);
     ObjectSetInteger(0,"TotalLots",OBJPROP_BACK,false);
     } 
//-------------------------------------Create Objects (Variable)-------------------------
   void ObjVA(){
           ObjectCreate(0,"VaTotalsig",OBJ_LABEL,0,0,0);
           ObjectSetInteger(0,"VaTotalsig",OBJPROP_XDISTANCE,135);
           ObjectSetInteger(0,"VaTotalsig",OBJPROP_YDISTANCE,64);
           ObjectSetString(0,"VaTotalsig",OBJPROP_TEXT,(string)(OrderTotal));
           ObjectSetInteger(0,"VaTotalsig",OBJPROP_BACK,false);
           ObjectSetInteger(0,"VaTotalsig",OBJPROP_FONTSIZE,12);
           ObjectSetInteger(0,"VaTotalsig",OBJPROP_COLOR,clrGold);
           ObjectSetInteger(0,"VaTotalsig",OBJPROP_BACK,false);
           
           ObjectCreate(0,"Win",OBJ_LABEL,0,0,0);
           ObjectSetInteger(0,"Win",OBJPROP_XDISTANCE,55);
           ObjectSetInteger(0,"Win",OBJPROP_YDISTANCE,114);
           ObjectSetString(0,"Win",OBJPROP_TEXT,(string)(Win));
           ObjectSetInteger(0,"Win",OBJPROP_BACK,false);
           ObjectSetInteger(0,"Win",OBJPROP_FONTSIZE,12);
           ObjectSetInteger(0,"Win",OBJPROP_COLOR,clrGold);
           ObjectSetInteger(0,"Win",OBJPROP_BACK,false);
           
           ObjectCreate(0,"Loss",OBJ_LABEL,0,0,0);
           ObjectSetInteger(0,"Loss",OBJPROP_XDISTANCE,64);
           ObjectSetInteger(0,"Loss",OBJPROP_YDISTANCE,139);
           ObjectSetString(0,"Loss",OBJPROP_TEXT,(string)(Loss));
           ObjectSetInteger(0,"Loss",OBJPROP_BACK,false);
           ObjectSetInteger(0,"Loss",OBJPROP_FONTSIZE,12);
           ObjectSetInteger(0,"Loss",OBJPROP_COLOR,clrGold);
           ObjectSetInteger(0,"Loss",OBJPROP_BACK,false);
           
           ObjectCreate(0,"Accuracy",OBJ_LABEL,0,0,0);
           ObjectSetInteger(0,"Accuracy",OBJPROP_XDISTANCE,103);
           ObjectSetInteger(0,"Accuracy",OBJPROP_YDISTANCE,164);
           ObjectSetString(0,"Accuracy",OBJPROP_TEXT,Accuracy+"%");
           ObjectSetInteger(0,"Accuracy",OBJPROP_BACK,false);
           ObjectSetInteger(0,"Accuracy",OBJPROP_FONTSIZE,12);
           ObjectSetInteger(0,"Accuracy",OBJPROP_COLOR,clrGold);
           ObjectSetInteger(0,"Accuracy",OBJPROP_BACK,false);
          
           ObjectCreate(0,"TotalLotsVA",OBJ_LABEL,0,0,0);
           ObjectSetInteger(0,"TotalLotsVA",OBJPROP_CORNER,CORNER_LEFT_UPPER);
           ObjectSetInteger(0,"TotalLotsVA",OBJPROP_XDISTANCE,104);
           ObjectSetInteger(0,"TotalLotsVA",OBJPROP_YDISTANCE,89);
           ObjectSetString(0,"TotalLotsVA",OBJPROP_TEXT,(string)TotalLots);
           ObjectSetInteger(0,"TotalLotsVA",OBJPROP_FONTSIZE,12);
           ObjectSetInteger(0,"TotalLotsVA",OBJPROP_COLOR,clrGold);
           ObjectSetInteger(0,"TotalLotsVA",OBJPROP_BACK,false);
           }
//------------------------------------OnChartEvent---------------------------------------------
 void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam){
       if(id==CHARTEVENT_OBJECT_CLICK&&sparam=="Clear"){
          ObjectSetInteger(0,"Clear",OBJPROP_STATE,false);
          Sleep(50);
          CloseOrderEnd();
          ObjectsDeleteAll();
          SendMail("INTER MODEL","Your expert has been removed by user.");
          SendNotification("INTER MODEL has been removed by user.");
          Alert("Expert has been removed by user");
          ExpertRemove();
          }
      }   
//------------------------------------------------OnInit-------------------
 int OnInit()
    {
  if(AccountNumber()!=ID&&IsTesting()==false&&IsDemo()==false){
     Alert("Incorrect Account Number");
     return(INIT_PARAMETERS_INCORRECT);}
  if(AccountNumber()==ID||IsTesting()==true||IsDemo()==true){
      CreateObjectCon1();
      CreateClear();
      ProfitFactor=(int)(AccountBalance()/FirstBalance());
    if((double)MarketInfo(Symbol(),MODE_MINLOT)==0.01){ 
     if(MarketInfo(Symbol(),MODE_DIGITS)==5&&MarketInfo(Symbol(),MODE_LOTSIZE)==100000){ 
      Factor=100000;
      LotS=FloorFirstBal()/Factor;
      if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT);
      if((double)FirstBalance()/(double)100000<0.01)Alert("Your capital money is not suitable for using this EA operation.");}
   else if(MarketInfo(Symbol(),MODE_DIGITS)==4&&MarketInfo(Symbol(),MODE_LOTSIZE)==100000){
      Tarket_Profit=80;
      LotS=FloorFirstBal()/Factor;
      Stop_Loss=40;
      if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT);  
      if(FirstBalance()/100000<0.01)Alert("Your capital money is not suitable for using this EA operation.");}
   else if(MarketInfo(Symbol(),MODE_DIGITS)==4&&MarketInfo(Symbol(),MODE_LOTSIZE)==10000){
      Factor=10000;
      Tarket_Profit=80;
      Stop_Loss=40;
      LotS=FloorFirstBal()/10000;
      if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT);  
      if(FirstBalance()/10000<0.01)Alert("Your capital money is not suitable for using this EA operation.");   }
       }
    else if((double)MarketInfo(Symbol(),MODE_MINLOT)==0.1){
       if(MarketInfo(Symbol(),MODE_DIGITS)==5&&MarketInfo(Symbol(),MODE_LOTSIZE)==100000){ 
      Factor=100000;
      LotS=FloorFirstBal()/100000;
      if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT); 
      if(FirstBalance()/100000<0.1) Alert("Your capital money is not suitable for using this EA operation.");}
   else if(MarketInfo(Symbol(),MODE_DIGITS)==4&&MarketInfo(Symbol(),MODE_LOTSIZE)==100000){
      Tarket_Profit=80;
      LotS=FloorFirstBal()/Factor;
      Stop_Loss=40;
      if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT); 
      if(FirstBalance()/100000<0.1) Alert("Your capital money is not suitable for using this EA operation.");}
   else if(MarketInfo(Symbol(),MODE_DIGITS)==4&&MarketInfo(Symbol(),MODE_LOTSIZE)==10000){
      Factor=10000;
      Tarket_Profit=80;
      Stop_Loss=40;
      LotS=FloorFirstBal()/10000;
      if(LotS<(double)MarketInfo(Symbol(),MODE_MINLOT)) LotS=(double)MarketInfo(Symbol(),MODE_MINLOT); 
      if(FirstBalance()/10000<0.1)Alert("Your capital money is not suitable for using this EA operation.");}
        }
       }
     return(INIT_SUCCEEDED);
   } 
//--------------------------------------CountOrder-----------------------------
int Countorder(int type){
   int Cnt=0;
     for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderType()==type&&OrderSymbol()==Symbol()){
             if(OrderMagicNumber()==Magicnumber){
              Cnt++;
          }
         }
        }
       }
      return(Cnt);
     }
//---------------------------------------OnTick---------------------------        
void Working();
void OnTick() {
CountWOL();
CountLots();
          Working();
          if(OrderTotal>0){ 
           CreateObjectCon2();
           CalAccuracy();
           ObjVA();
          }     
        }
       
//-----------------------------------------OnDeInit----------------------
  void OnDeinit(const int reason)
    {
     
     ObjectsDeleteAll();
    
     }  
//----------------------------------------Check repeating order---------------------
bool checkrep(int type){
  bool A=false; 
   for(int i=OrdersHistoryTotal()-1;i>=0;i--){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true){
     if(Symbol()==OrderSymbol()&&OrderMagicNumber()==Magicnumber){
      i=-1;
      if(OrderType()==type){
       if(TimeHour(OrderOpenTime())==TimeHour(TimeCurrent())&&TimeDay(OrderOpenTime())==TimeDay(TimeCurrent())){
        A=true;
            }
           }  
          }
         }
        }
    return(A);
     }          
//------------------------------------------------Working------------------------------
 void Working(){
  getCCI();
    if(Countorder(OP_BUY)==0){
       if(Value1==1.00&&Value1sh==0.00){      
          if(checkrep(OP_BUY)==false){
               CloseOrder(OP_SELL);  
               openbuy();  
               CountLots();   
            } 
          }
        }
      if(Countorder(OP_SELL)==0){
        if(Value1==0.00&&Value1sh==1.00){      
         if(checkrep(OP_SELL)==false){
             CloseOrder(OP_BUY);
             opensell();
             CountLots();
        }
       }      
      } 
      Trailling();
     }  

void Trailling(){
    int i;
      
      if(CountOrderAll() == 1){
       if(OrderSelect(i = OrdersTotal()-1, SELECT_BY_POS, MODE_TRADES)){
        if(OrderMagicNumber() == Magicnumber && OrderSymbol() == Symbol()){
         switch (OrderType()){
           case OP_BUY: 
             if(Ask >= OrderOpenPrice() + Tarket_Profit*Point && OrderOpenPrice() != OrderStopLoss()){
              while(!OrderModify(OrderTicket(), 0, OrderOpenPrice(), 0, 0, clrNONE)) continue;
               break;
                  
                 } 
                 
           case OP_SELL:
             if(Bid <= OrderOpenPrice() - Tarket_Profit*Point && OrderOpenPrice() != OrderStopLoss()){
              while(!OrderModify(OrderTicket(), 0, OrderOpenPrice(), 0, 0, clrNONE)) continue;   
               break;
                  
                 }
                }
               }
              }
             }     
            } 
                       