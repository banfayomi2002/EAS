//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Average sample expert advisor"

#define MAGICMA  20151008
//--- Inputs
extern int FastEMA = 8;
extern int SlowEMA = 17;
extern int SignalSMA = 9;
extern bool Show_MAJOR_TREND = true;
extern bool Show_TREND_ANALYSIS = true;
extern double lot = 0.1;
extern int takeprofit=1000;
extern int TrailingStop = 0;
input int    MovingPeriod  =20;
input int    MovingShift   =0;
extern int stoploss =0;
bool buy = false;
bool sell = false;
bool close = false;
double takeprofit1, takeprofit2;
string  trend_signal, trend_main, trend_level;
    color   color_m1, color_m5, color_m15, color_m30, color_h1, color_h4, color_d1, color_w1, color_mn,
            color_signal, color_main, color_level;
double spread =Ask-Bid;
//double one, two, three, four, five, six, seven;
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
    double one = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 0, 0);
    double two = iCustom(NULL, 0, "#4x 4 system alert(1)", 0,1, 0);
    double three = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 2, 0);
    double four = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 3, 0);
    double five = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 4,0);
    double six = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 5, 0);
    double seven = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 6, 0);
  
  double macd_M1=iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM1=iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_M5=iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM5=iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    double macd_M15=iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM15=iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    double macd_M30=iMACD(NULL,PERIOD_M30,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM30=iMACD(NULL,PERIOD_M30,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_H1=iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_HH1=iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    double macd_H4=iMACD(NULL,PERIOD_H4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_HH4=iMACD(NULL,PERIOD_H4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 

    if (Show_MAJOR_TREND == true)
    {
    double macd_D1=iMACD(NULL,PERIOD_D1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_DD1=iMACD(NULL,PERIOD_D1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_W1=iMACD(NULL,PERIOD_W1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_WW1=iMACD(NULL,PERIOD_W1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_MN1=iMACD(NULL,PERIOD_MN1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MMN1=iMACD(NULL,PERIOD_MN1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    }
        
  
           
    // UP Data
    if ((macd_M5 > macd_MM5) && (macd_M1 > macd_MM1)) { trend_signal = "TREND/UP"; color_signal = Lime;}
     //Down Data   
    if ((macd_M5 < macd_MM5) && (macd_M1 < macd_MM1)) { trend_signal = "TREND/DN"; color_signal = Red; }
    
    //Consolidation Data
    if ((macd_M5 < macd_MM5) && (macd_M1 > macd_MM1)) { trend_signal = "SIDEWAY"; color_signal = Orange; }
    if ((macd_M5 > macd_MM5) && (macd_M1 < macd_MM1)) { trend_signal = "SIDEWAY"; color_signal = Orange; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 > macd_HH1)&& (macd_H4 < macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 < macd_HH1)&& (macd_H4 > macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
     
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    
    
    if ((macd_M5 > macd_MM5) && (macd_M15 > macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1) && (macd_H4 > macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    if ((macd_M5 < macd_MM5) && (macd_M15 < macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 >macd_HH1) && (macd_H4 < macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 > macd_HH1)) { trend_main = "TREND/UP"; color_main = YellowGreen; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 < macd_HH1)) { trend_main = "TREND/DN"; color_main = Tomato; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 > macd_HH1)) { trend_main = "TREND/DN"; color_main = Tomato; }
    if ((macd_M15 > macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1)) { trend_main = "TREND/UP"; color_main = YellowGreen; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1)) { trend_main = "TREND/DN"; color_main = Red; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 > macd_HH1)) { trend_main = "TREND/UP"; color_main = Lime; }
    
    if ((macd_M5 < macd_MM5) && (macd_M15 < macd_MM15) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
    if ((macd_M5 > macd_MM5) && (macd_M15 > macd_MM15) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
    
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 < macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 > macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 > macd_HH4)) { trend_level = "STRONG"; color_level = Yellow; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 < macd_HH4)) { trend_level = "STRONG"; color_level = Yellow; }
    
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 > macd_HH4)) { trend_main = "TREND/UP"; color_main = Lime; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 < macd_HH4)) { trend_main = "TREND/DN"; color_main = Red; }
    
     
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 < macd_HH4)) { trend_main = "TREND/UP"; color_main = Lime; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 > macd_HH4)) { trend_main = "TREND/DN"; color_main = Red; }              
    
    

    //Analysis
    if (Show_TREND_ANALYSIS == true)
    {
      color color_ta, color_ca;
      string analysis_today, analysis_current;

      //Today Analysis UP
      if ((macd_H4 > macd_HH4) && (macd_D1 > macd_DD1)) { analysis_today = "TREND/UP"; color_ta = Lime; }
      if ((macd_H4 < macd_HH4) && (macd_D1 > macd_DD1)) { analysis_today = "TREND/UP"; color_ta = YellowGreen; }
    
      //Today Analysis UP    
      if ((macd_H4 < macd_HH4) && (macd_D1 < macd_DD1)) { analysis_today = "TREND/DN"; color_ta = Red; }
      if ((macd_H4 > macd_HH4) && (macd_D1 < macd_DD1)) { analysis_today = "TREND/DN"; color_ta = Tomato; }

      //Current Analysis    
      if ((macd_HH1 > 0) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "TREND/UP"; color_ca = Lime; }
      if ((macd_HH1 < 0) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "TREND/UP"; color_ca = Lime; }
      if ((macd_HH1 < 0) && (macd_H1 < macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "CORRECTION"; color_ca = Green; }
      if ((macd_HH1 < 0) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "TREND/UP"; color_ca = YellowGreen; }
      if ((macd_HH1 < 0) && (macd_H1 > macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "TREND/UP"; color_ca = YellowGreen; }
      if ((macd_HH1 > 0) && (macd_H1 < macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "CORRECTION"; color_ca = Green; }
      if ((macd_HH1 > 0) && (macd_H1 > macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 > macd_DD1)) { analysis_current = "TREND/UP"; color_ca = YellowGreen; }

      if ((macd_HH1 < 0) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "TREND/DN"; color_ca = Red; }
      if ((macd_HH1 > 0) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "TREND/DN"; color_ca = Red; }
      if ((macd_HH1 > 0) && (macd_H1 > macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "CORRECTION"; color_ca = FireBrick; }
      if ((macd_HH1 > 0) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "TREND/DN"; color_ca = Tomato; }
      if ((macd_HH1 > 0) && (macd_H1 < macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "TREND/DN"; color_ca = Tomato; }
      if ((macd_HH1 < 0) && (macd_H1 > macd_HH1) && (macd_H4 < macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "CORRECTION"; color_ca = FireBrick; }
      if ((macd_HH1 < 0) && (macd_H1 < macd_HH1) && (macd_H4 > macd_HH4) && (macd_D1 < macd_DD1)) { analysis_current = "TREND/DN"; color_ca = Tomato; }
    }
            
    
   double ma;
   int    res;
   
   /////////////////////////////////////////////////////////////////
   double stoplos,stoplos1;
    datetime FiboTime1, FiboTime2; 
   double rates[1][6],yesterday_close,yesterday_high,yesterday_low, open;
   ArrayCopyRates(rates,Symbol(),PERIOD_D1);
//----
   if(DayOfWeek()==1)
     {
      if(TimeDayOfWeek(iTime(Symbol(),PERIOD_D1,1))==5)
        {
         yesterday_close= rates[1][4];
         yesterday_high = rates[1][3];
         open = rates[1][1];
         yesterday_low=rates[1][2];
       
        }
      else
        {
         for(int d=5;d>=0;d--)
           {
            if(TimeDayOfWeek(iTime(Symbol(),PERIOD_D1,d))==5)
              {
               yesterday_close= rates[d][4];
               yesterday_high = rates[d][3];
               open = rates[d][1];
               yesterday_low=rates[d][2];
              }

           }
        }
     }
   else
     {
      yesterday_close= rates[1][4];
      yesterday_high = rates[1][3];
       open = rates[1][1];
      yesterday_low=rates[1][2];
     }
//---- Calculate Pivots
   Comment("\nYesterday quotations:\nH ",yesterday_high,"\nL ",yesterday_low,"\nC ",yesterday_close);
   double R=yesterday_high-yesterday_low;//range
    double p=(yesterday_high+yesterday_low+yesterday_close)/3;// Standard Pivot
   double r3 = p + (R * 1.000);
   double r2 = p + (R * 0.618);
   double r1 = p + (R * 0.382);
  double s1 = p - (R * 0.382);
   double s2 = p - (R * 0.618);
  double s3 = p - (R * 1.000);
  
  r1 = NormalizeDouble(r1,_Digits);
    r2 = NormalizeDouble(r2,_Digits);
  p = NormalizeDouble(p,_Digits);
  r3 = NormalizeDouble(r3,_Digits);
   s1 = NormalizeDouble(s1,_Digits);
 s2= NormalizeDouble(s2,_Digits);
 s3 = NormalizeDouble(s3,_Digits);
  ////////////////////////////////////////////////////////////

   if((Ask < r1) && (Ask < r2) && (Ask < r3 ) && (Ask > s1 )){
   RefreshRates();
   takeprofit1 = r1; stoplos = s1 - spread;}
   
   if((Ask > r1) && (Ask < r2) && (Ask < r3 )&& (Ask < s1) && (Ask > s2)){
   RefreshRates();
   takeprofit1 = r2; stoplos = s2 - spread;}
   
    if((Ask > r1) && (Ask > r2) && (Ask < r3 )&& (Ask < s1) && (Ask < s2)&& (Ask > s3)){
    RefreshRates();
   takeprofit1 = r3; stoplos = s3 - spread;}
   
   
    if((Bid > s1) && (Bid > s2) && (Bid > s3 ) && (Bid < r1 )){
    RefreshRates();
   takeprofit2 = s1; stoplos1 = r1 + spread;}
   
   if((Bid < s1) && (Bid > s2) && (Bid > s3 )&& (Bid < r1) && (Bid < r2)){
   RefreshRates();
   takeprofit2 = s2; stoplos1 = s1 + spread;}
   
    if((Bid < s1) && (Bid < s2) && (Bid > s3 )&& (Bid < r1) && (Bid < r2)&& (Bid < r3)){
    RefreshRates();
   takeprofit2 = s3; stoplos1 = s2 + spread;}
   
   
   
   
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
      ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
//--- sell conditions
   
   
   
    ////////////////////////////////////////////////////
//--- get Moving Average 
  if((analysis_current == "TREND/UP") && (analysis_today== "TREND/UP") && (trend_signal== "TREND/UP")&& (trend_level=="STRONG")){buy = true;}
  //sell
    if((analysis_current == "TREND/DN") && (analysis_today== "TREND/DN") && (trend_signal ==  "TREND/DN")&&(trend_level=="STRONG")){sell =true;}
//--- sell conditions
//exit
 two = NormalizeDouble(two,_Digits);
  one = NormalizeDouble(one,_Digits);
  stoplos =Bid - 80* Point + spread;
  stoplos1 = Ask + (80*Point+spread);
if(analysis_current == "CORRECTION"){close=true;}

   if(one !=EMPTY_VALUE && three !=EMPTY_VALUE && five !=EMPTY_VALUE)
     {
     res=OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,0,"",MAGICMA,0,Blue);
     
      return;
     }
//--- buy conditions
   if(two !=EMPTY_VALUE && four !=EMPTY_VALUE && six !=EMPTY_VALUE)
     {
       res=OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,0,"",MAGICMA,0,Red);
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   double ma, fasterEMAnow;
   RefreshRates();
//--- go trading only for first tiks of new bar
   double one = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 0, 0);
    double two = iCustom(NULL, 0, "#4x 4 system alert(1)", 0,1, 0);
    double three = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 2, 0);
    double four = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 3, 0);
    double five = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 4,0);
    double six = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 5, 0);
    double seven = iCustom(NULL, 0, "#4x 4 system alert(1)", 0, 6, 0);
  
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(two != EMPTY_VALUE && four != EMPTY_VALUE && six != EMPTY_VALUE)
           {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
               return;
           }
           if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
         return;
        }
      if(OrderType()==OP_SELL)
        {
         if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
         if(one != EMPTY_VALUE && three != EMPTY_VALUE && five != EMPTY_VALUE)
            {
           
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
                 return;
           }
      
        
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false)
      return;
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//---
  }
//+------------------------------------------------------------------+
