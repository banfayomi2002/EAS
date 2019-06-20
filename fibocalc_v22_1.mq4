//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  20131100
//--- input parameters
//input int      Input1=0;
//--- Inputs
input double Lots          =0.1;
input double MaximumRisk   =0.02;
input double DecreaseFactor=3;
input int    MovingPeriod  =12;
input int    MovingShift   =6;
extern int Trailingstop = 30;
//---- INPUT INDICATOR PARAMETERS
extern int period0 = 15;
extern int period1 = 15;
extern int period2 = 15;

//---- buffers
double PrevDayHiBuffer[];
double PrevDayLoBuffer[];
double PrevDayOpenBuffer[];
double PrevDayCloseBuffer[];
extern int TrailingGap = 10;
//----
bool opbuy = false;
bool opsell = false;
int fontsize = 8;
int res;
double spread;
double PipValue=1;

double PrevDayHi, PrevDayLo, PrevDayOpen , PrevDayClose, fb, fs, fe, tp1, tp2, tp3;
double LastHigh, LastLow, LastOpen, LastClose, x;
double ri, re1, re2, re3, ra1, ra2, ra3;
double sl, tp;
double kline[3], dline[3];
bool crossedup, crosseddown;
int longtkt, shorttkt, cnt, t;
  double p;
   double r3;
   double r2;
   double r1;
   double s1;
   double s2;
   double s3;
   double sloss,bloss;
   
  double buy, stop1, stop2, sell, takeprofit1, takeprofit2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     //--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
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

int start() 
  {
  if(Volume[0]>1) return (0);
  RefreshRates();
  spread =Ask-Bid;
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
    p=(yesterday_high+yesterday_low+yesterday_close)/3;// Standard Pivot
   r3 = p + (R * 1.000);
    r2 = p + (R * 0.618);
   r1 = p + (R * 0.382);
   s1 = p - (R * 0.382);
    s2 = p - (R * 0.618);
  s3 = p - (R * 1.000);
  ////////////////////////////////////////////////////////////
  
 sell = R * 0.382 + yesterday_low;
 buy = yesterday_high - (yesterday_high - yesterday_low) * 0.382;
 stop1 = buy * 0.618;
 stop2 = R * 0.618 + yesterday_low;
 takeprofit1 = R * 0.618 + buy;
 takeprofit2 = (yesterday_low - yesterday_high) * 0.618 + sell;
 //////////////////////////////////////////////////////////////

 
   ///////////////////////////////////////////////////////////
   
    crossedup = false;
   crosseddown = false;

   for(int i = 0;i < 3;i++)
   {
      kline[i] = iStochastic(NULL, Period(), 8, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      dline[i] = iStochastic(NULL, Period(), 8, 3, 3, MODE_SMA, 0, MODE_SIGNAL, i); 
   }
   if ((kline[1] < dline[1]) && (kline[2] > dline[2])) crosseddown = true;
   else if ((kline[1] > dline[1]) && (kline[2] < dline[2])) crossedup = true;
   else return(0);
   //if (crossedup && (kline[1] < 20.0));
   //if (crosseddown && (kline[1] > 80.0));
   
   ///////////////////////////////////////////////////////////
      double ma;
      ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
   
   /////////////////////////////////////////////////////////////
   
  
  int i;
   //---- Checking whether the bars number is enough for further calculation
   if(Bars < period0 + period1 + period2)
       return(0);
//---- INDICATOR BUFFERS EMULATION
   if(ArraySize(PrevDayHiBuffer) < Bars)
     {
       ArraySetAsSeries(PrevDayHiBuffer, false);
       ArraySetAsSeries(PrevDayLoBuffer, false);
       ArraySetAsSeries(PrevDayOpenBuffer, false);
       ArraySetAsSeries(PrevDayCloseBuffer, false);
       //----  
       ArrayResize(PrevDayHiBuffer, Bars); 
       ArrayResize(PrevDayLoBuffer, Bars); 
       ArrayResize(PrevDayOpenBuffer, Bars); 
       ArrayResize(PrevDayCloseBuffer, Bars); 
       //----
       ArraySetAsSeries(PrevDayHiBuffer, true);
       ArraySetAsSeries(PrevDayLoBuffer, true);
       ArraySetAsSeries(PrevDayOpenBuffer, true); 
       ArraySetAsSeries(PrevDayCloseBuffer, true);
     } 
//----+ INSERTION OF A STATIC INTEGER MEMORY VARIABLE
   static int IndCounted;
//----+ Insertion of variables with a floating point
   double Resalt0, Resalt1, Resalt2;
//----+ Insertion of integer variables and getting calculated bars
   int limit, MaxBar, bar, counted_bars = IndCounted;
//---- checking for possible errors
   if(counted_bars < 0)
       return(-1);
//---- the last calculated bar must be recalculated 
   if(counted_bars > 0) 
       counted_bars--;
//----+ REMEMBERING THE AMOUNT OF ALL BARS OF THE CHART
   IndCounted = Bars - 1;
//---- defining the number of the oldest bar, 
//     starting from which new bars will be recalculated
   limit = Bars - counted_bars - 1; 
//---- defining the number of the oldest bar, 
//     starting from which new bars will be recalculated
   MaxBar = Bars - 1 - (period0 + period1 + period2); 
//---- initialization of zero 
   if(limit > MaxBar)
     {
       limit = MaxBar;
       for(bar = Bars - 1; bar >= 0; bar--)
         {
           PrevDayHiBuffer[bar] = 0.0;
           PrevDayLoBuffer[bar] = 0.0;
           PrevDayOpenBuffer[bar] = 0.0;
            PrevDayOpenBuffer[bar] = 0.0;
         }
     }
//----
  
   for(i = limit; i >= 0; i--)
     {
       LastHigh = High[Highest(NULL, 0, MODE_HIGH, i + 1)];
       LastLow = Low[Lowest(NULL, 0, MODE_LOW, i + 1)];
       if(Open[i+1] > LastOpen) 
           LastOpen = Open[i+1];
       //----
       if(TimeDay(Time[i]) != TimeDay(Time[i+1]))
         {
           PrevDayHi = LastHigh;
           PrevDayLo = LastLow;
           PrevDayOpen = LastClose;
           PrevDayClose = Open[i];
           //----
           LastLow = Open[i];
           LastHigh = Open[i];
           LastOpen = Open[i];
           LastClose = Open[i];
           //----
          /* if(ObjectFind("PrevDayHi") != 0)
             {
               ObjectCreate("PrevDayHi", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayHi", "                Day High", fontsize, "Arial", Black);
             }
           else
             {
               ObjectMove("PrevDayHi", 0, Time[i], PrevDayHi);
             }
           //----
           if(ObjectFind("PrevDayLo") != 0)
             {
               ObjectCreate("PrevDayLo", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayLo", "                Day Low", fontsize, "Arial", Black);
             }
           else
             {
               ObjectMove("PrevDayLo", 0, Time[i], PrevDayLo);
             }
           //----
           if(ObjectFind("PrevDayOpen") != 0)
             {
               ObjectCreate("PrevDayOpen", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayOpen", "                Prev. Day Open", fontsize, 
                             "Arial", White);
             }
           else
             {
               ObjectMove("PrevDayOpen", 0, Time[i], PrevDayOpen);
             }
           //----
           if(ObjectFind("PrevDayClose") != 0)
             {
               ObjectCreate("PrevDayClose", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayClose", "                Prev. Day Close", fontsize, 
                             "Arial", Black);
             }
           else
             {
               ObjectMove("PrevDayClose", 0, Time[i], PrevDayClose);
             }*/

         }
       PrevDayHiBuffer[i] = PrevDayHi;
       PrevDayLoBuffer[i] = PrevDayLo;
       PrevDayOpenBuffer[i] = PrevDayOpen;
       PrevDayCloseBuffer[i] = PrevDayClose;
     }
// BUY
   if(Ask>LastClose) 
     {
       double bloss = NormalizeDouble(p,_Digits)- spread;
       r3 = NormalizeDouble(r3,_Digits);
       r2 =  NormalizeDouble(r2,_Digits);
       r1 =  NormalizeDouble(r1,_Digits)- spread;
       fb = PrevDayHi - (PrevDayHi - PrevDayLo)*0.382;
       fe = PrevDayHi - (PrevDayHi - PrevDayLo)*0.618;
       tp1 = ((PrevDayHi - PrevDayLo)*0.618) + fb;
       tp2 = (PrevDayHi - PrevDayLo) + fb;
       tp3 = 1.618*(PrevDayHi - PrevDayLo) + fb;
       ri = MathRound((fb - fe)*10000) / 10000;
       re1=MathRound((tp1 - fb)*10000) / 10000;
       re2=MathRound((tp2 - fb)*10000) / 10000;
       re3=MathRound((tp3 - fb)*10000) / 10000;
       ra1=MathRound((re1 / ri)*10) / 10;
       ra2=MathRound((re2 / ri)*10) / 10;
       ra3=MathRound((re3 / ri)*10) / 10;
       
       //////////////////////////////////////////////
       
       sell = R * 0.382 + yesterday_low;
       buy = yesterday_high - (yesterday_high - yesterday_low) * 0.382;
       stop1 = buy * 0.618;
       stop2 = R * 0.618 + yesterday_low;
       takeprofit1 = R * 0.618 + buy;
       takeprofit2 = (yesterday_low - yesterday_high) * 0.618 + sell;
       
       bloss = NormalizeDouble(stop1,_Digits)- (30*Point+spread);
       r3 = NormalizeDouble(r3,_Digits);
        takeprofit1 =  NormalizeDouble(takeprofit1,_Digits);
        buy =  NormalizeDouble(buy,_Digits)- spread;
       
       /////////////////////////////////////////////
       
         fb =  NormalizeDouble(fb,_Digits) - spread;
       //----
       if(ObjectFind("fb") != 0)
         {
           ObjectCreate("fb", OBJ_TEXT, 0, Time[0], fb);
           ObjectSetText("fb", " BUY LEVEL", 8, "Arial", EMPTY);
         }
       else
         {
           ObjectMove("fb",fb, Time[0], fb);
         }
       //----
       if(ObjectFind("fb Line") != 0)
         {
           ObjectCreate("fb Line", OBJ_HLINE, 0, Time[0],fb);
           ObjectSet("fb Line", OBJPROP_STYLE, STYLE_DASHDOT);
           ObjectSet("fb Line", OBJPROP_COLOR, Blue);
         }
       else
         {
           ObjectMove("fb Line",0, Time[0], fb);
         }
       //----
       if((ra1 > 2) && (ra2 > 2) && (ra3 > 2)&&(Ask <= buy)){
           Comment("Owner : ", AccountName()," Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was UP ",
           "\nBUY @ ",fb ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," OK Trade ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," OK Trade ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," OK Trade ");
          RefreshRates();
             res = OrderSend(Symbol(),OP_BUY,1,Ask,3,bloss,takeprofit1,"My order",MAGICMA,0,Red);
              opbuy = true;
             
           }
       else
           Comment("Owner : ", AccountName()," Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was UP ",
           "\nBUY @ ",fb ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," NO TRADE ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," NO TRADE ","\nTakeProit 3 ",tp3,
          " Risk/Reward Ratio : ", ra3 ," NO TRADE ");

     }
// SELL
   if(Bid<LastClose) 
     {
     double sloss = NormalizeDouble(p,_Digits) + spread;
     s3 = NormalizeDouble(s3,_Digits);
     s2 =  NormalizeDouble(s2,_Digits);
     s1 =  NormalizeDouble(s1,_Digits) + spread;
       fs = (PrevDayHi - PrevDayLo)*0.382 + (PrevDayLo);
       fe = (PrevDayHi - PrevDayLo)*0.618 + (PrevDayLo);
       tp1 = ((PrevDayLo - PrevDayHi)*0.618) + fs;
       tp2 = (PrevDayLo - PrevDayHi) + fs;
       tp3 = 1.618*(PrevDayLo - PrevDayHi) + fs;
       ri = MathRound((fs - fe)*10000) / 10000;
       re1 = MathRound((tp1 - fs)*10000) / 10000;
       re2 = MathRound((tp2 - fs)*10000) / 10000;
       re3 = MathRound((tp3 - fs)*10000) / 10000;
       ra1 = MathRound((re1 / ri)*10) / 10;
       ra2 = MathRound((re2 / ri)*10) / 10;
       ra3 = ((re3 / ri)*10) / 10;
       
       ///////////////////////////////////////////////////////
       
       sell = R * 0.382 + yesterday_low;
       buy = yesterday_high - (yesterday_high - yesterday_low) * 0.382;
       stop1 = buy * 0.618;
       stop2 = R * 0.618 + yesterday_low;
       takeprofit1 = R * 0.618 + buy;
       takeprofit2 = (yesterday_low - yesterday_high) * 0.618 + sell;
       
       sloss = NormalizeDouble(stop2,_Digits) + 30*Point+spread;
       s3 = NormalizeDouble(s3,_Digits);
      takeprofit2 =  NormalizeDouble(takeprofit2,_Digits);
       sell =  NormalizeDouble(sell,_Digits) + spread;
        
       //////////////////////////////////////////////////////
       
      fs =  NormalizeDouble(fs,_Digits) + spread;
       //----
      /* if(ObjectFind("fs") != 0)
         {
           ObjectCreate("fs", OBJ_TEXT, 0, Time[0], fs);
           ObjectSetText("fs", " SELL LEVEL", 8, "Arial", EMPTY);
         }
       else
         {
           ObjectMove("fs",fs, Time[0], fs);
         }
       //----
       if(ObjectFind("fs Line") != 0)
         {
           ObjectCreate("fs Line", OBJ_HLINE, 0, Time[0],fs);
           ObjectSet("fs Line", OBJPROP_STYLE, STYLE_DASHDOT);
           ObjectSet("fs Line", OBJPROP_COLOR, Red);
         }
       else
         {
           ObjectMove("fs Line",0, Time[0], fs);
         }*/
       //----
       if((ra1 > 2) && (ra2 > 2) && (ra3 > 2)&& (Bid >=sell)){
           Comment("Owner : ", AccountName(),"Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was Down ",
           "\nSELL @ ",fs ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," OK Trade ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," OK Trade ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," OK Trade ");
           RefreshRates();
          res=OrderSend(Symbol(),OP_SELL,1,Bid,3,sloss,takeprofit2,"My order",MAGICMA,0,Red);
          opsell = true;
           }
       else
           Comment("Owner : ", AccountName(),"Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was Down ",
           "\nSELL @ ",fs ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," NO TRADE ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," NO TRADE ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," NO TRADE ");
     }
//----
 /*  if(ObjectFind("fe") != 0)
     {
       ObjectCreate("fe", OBJ_TEXT, 0, Time[0], fe);
       ObjectSetText("fe", " STOPLOSS LEVEL", 8, "Arial", EMPTY);
     }
   else
     {
       ObjectMove("fe",fe, Time[0], fe);
     }
//----
   if(ObjectFind("fe Line") != 0)
     {
       ObjectCreate("fe Line", OBJ_HLINE, 0, Time[0],fe);
       ObjectSet("fe Line", OBJPROP_STYLE, STYLE_DASHDOT);
       ObjectSet("fe Line", OBJPROP_COLOR, OrangeRed );
     }
   else
     {
       ObjectMove("fe Line",0, Time[0], fe);
     }
//----
   if(ObjectFind("tp1") != 0)
     {
       ObjectCreate("tp1", OBJ_TEXT, 0, Time[0], tp1);
       ObjectSetText("tp1", " PROFIT TARGET 1", 8, "Arial", EMPTY);
     }
   else
     {
       ObjectMove("tp1",tp1, Time[0],tp1 );
     }
//----
   if(ObjectFind("tp1 Line") != 0)
     {
       ObjectCreate("tp1 Line", OBJ_HLINE, 0, Time[0],tp1);
       ObjectSet("tp1 Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
       ObjectSet("tp1 Line", OBJPROP_COLOR, SpringGreen );
     }
   else
     {
       ObjectMove("tp1 Line",0, Time[0],tp1 );
     }
//----
   if(ObjectFind("tp2") != 0)
     {
       ObjectCreate("tp2", OBJ_TEXT, 0, Time[0], tp2);
       ObjectSetText("tp2", " PROFIT TARGET 2", 8, "Arial", EMPTY);
     }
   else
     {
       ObjectMove("tp2",tp2, Time[0],tp2);
     }
   if(ObjectFind("tp2 Line") != 0)
     {
       ObjectCreate("tp2 Line", OBJ_HLINE, 0, Time[0],tp2);
       ObjectSet("tp2 Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
       ObjectSet("tp2 Line", OBJPROP_COLOR, SpringGreen );
     }
   else
     {
        ObjectMove("tp2 Line",0, Time[0],tp2);
     }
//----
   if(ObjectFind("tp3") != 0)
     {
       ObjectCreate("tp3", OBJ_TEXT, 0, Time[0], tp3);
       ObjectSetText("tp3", " PROFIT TARGET 3", 8, "Arial", EMPTY);
     }
   else
     {
       ObjectMove("tp3",tp3, Time[0], tp3);
     }
//----
   if(ObjectFind("tp3 Line") != 0)
     {
       ObjectCreate("tp3 Line", OBJ_HLINE, 0, Time[0],tp3);
       ObjectSet("tp3 Line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
       ObjectSet("tp3 Line", OBJPROP_COLOR, SpringGreen );
     }
   else
     {
       ObjectMove("tp3 Line",0, Time[0],tp3);
     }*/
//----
   return(0);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //---
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
  }
  
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void TrailingStop()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
           {
            double takeprofit=OrderTakeProfit();

            if(OrderType()==OP_BUY && Ask-OrderOpenPrice()>Trailingstop*PipValue*Point)
              {
              
                  bool ret1=OrderModify(OrderTicket(),OrderOpenPrice(),Ask-Trailingstop*PipValue*Point,takeprofit1,OrderExpiration(),White);
                  
                 }
              }
            if(OrderType()==OP_SELL && OrderOpenPrice()-Bid>Trailingstop*PipValue*Point)
              {
         
                  bool ret2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid+Trailingstop*PipValue*Point,takeprofit2,OrderExpiration(),White);
                
                 }
              }
           
   
  }

//---


void OnTick()
  {
  //if(Bars<100 || IsTradeAllowed()==false){
     // return;
     // }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0)
  start();
  else
  TrailingStop();
   //Print("OrderClose error ",GetLastError());
  
//--- 
   
   }

