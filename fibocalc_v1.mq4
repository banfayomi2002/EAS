/*+------------------------------------------------------------------+
 |                                                         FiboCalc  |
 |                                         Author: Copyright © 2006, |
 |                                                                   |
 |                                                                   |
 +------------------------------------------------------------------+*/
#property copyright "Copyright © 2006,"
#property link      "http://www.mql4.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DarkGreen
#property indicator_color2 Maroon
#property indicator_color3 Magenta
#property indicator_color4 Goldenrod

#define MAGICMA  20151111
//--- Inputs
input double Lots          =0.1;
input double MaximumRisk   =0.02;
input double DecreaseFactor=3;
input int    MovingPeriod  =12;
input int    MovingShift   =6;
//---- buffers
double PrevDayHiBuffer[];
double PrevDayLoBuffer[];
double PrevDayOpenBuffer[];
double PrevDayCloseBuffer[];
//----
int fontsize = 8;
double PrevDayHi, PrevDayLo, PrevDayOpen , PrevDayClose, fb, fs, fe, tp1, tp2, tp3;
double LastHigh, LastLow, LastOpen, LastClose, x;
double ri, re1, re2, re3, ra1, ra2, ra3;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()
  {
   ObjectDelete("PrevDayHi");
   ObjectDelete("PrevDayLo");
   ObjectDelete("PrevDayOpen");
   ObjectDelete("PrevDayClose");
   ObjectDelete("fe");
   ObjectDelete("fe Line");
   ObjectDelete("fs");
   ObjectDelete("fs Line");
   ObjectDelete("tp3");
   ObjectDelete("tp3 Line");
   ObjectDelete("tp2");
   ObjectDelete("tp2 Line");
   ObjectDelete("tp1");
   ObjectDelete("tp1 Line");
   ObjectDelete("fb");
   ObjectDelete("fb Line");
//----
   return(0);
  }
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
//----
   SetIndexBuffer(0, PrevDayHiBuffer);
   SetIndexBuffer(1, PrevDayLoBuffer);
   SetIndexBuffer(2, PrevDayOpenBuffer);
   SetIndexBuffer(3, PrevDayCloseBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="Prev Hi-Lo levels";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   SetIndexLabel(1, "Maroon");
   SetIndexLabel(2, "Magenta");
   SetIndexLabel(3, "Goldenrod");      
//----
   SetIndexDrawBegin(0,1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()  
  {
  int res;
   int counted_bars = IndicatorCounted();
   int limit, i;
//---- indicator calculation
   if(counted_bars == 0)
     {
       x = Period();
       if(x > 240) 
           return(-1);
     }
   limit = (Bars - counted_bars) - 1;
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
           if(ObjectFind("PrevDayHi") != 0)
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
             }

         }
       PrevDayHiBuffer[i] = PrevDayHi;
       PrevDayLoBuffer[i] = PrevDayLo;
       PrevDayOpenBuffer[i] = PrevDayOpen;
       PrevDayCloseBuffer[i] = PrevDayClose;
     }


 
  // BUY
   if(Ask > LastClose) 
     {
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
       if((ra1 > 2) && (ra2 > 2) && (ra3 > 2)){
           Comment("Owner : ", AccountName()," Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was UP ",
           "\nBUY @ ",fb ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," OK Trade ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," OK Trade ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," OK Trade ");
         res = OrderSend(Symbol(),OP_BUYSTOP,LotsOptimized(),fb,3,fe,tp1,"My order",MAGICMA,0,Red);
         }
     
       else{
           Comment("Owner : ", AccountName()," Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was UP ",
           "\nBUY @ ",fb ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," NO TRADE ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," NO TRADE ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," NO TRADE ");
         
           }
             return res;
     }
// SELL
   if(Bid < LastClose) 
     {
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
       //----
       if(ObjectFind("fs") != 0)
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
         }
       //----
       if((ra1 > 2) && (ra2 > 2) && (ra3 > 2)){
           Comment("Owner : ", AccountName(),"Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was Down ",
           "\nSELL @ ",fs ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," OK Trade ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," OK Trade ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," OK Trade ");
          res = OrderSend(Symbol(),OP_SELLSTOP,LotsOptimized(),fb,3,fe,tp1,"My order",MAGICMA,0,Red);
          }
       else
       {
           Comment("Owner : ", AccountName(),"Account number : ", AccountNumber(),
           "\n\nPrevDayHi ",PrevDayHi,"\nPrevDayLo ", PrevDayLo,"\nTrend was Down ",
           "\nSELL @ ",fs ,"\nStopLoss ",fe,"\nTakeProit 1 ",tp1 ,
           " Risk/Reward Ratio : ", ra1 ," NO TRADE ","\nTakeProit 2 ",tp2 ,
           " Risk/Reward Ratio : ", ra2 ," NO TRADE ","\nTakeProit 3 ",tp3,
           " Risk/Reward Ratio : ", ra3 ," NO TRADE ");
         
          }
           return res;
     }
//----
   if(ObjectFind("fe") != 0)
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
     }
//----
  return(0);
  }
  
  
  //+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   double ma;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(Open[1]>ma && Close[1]<ma)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(Open[1]<ma && Close[1]>ma)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
     }
//---
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false)
      return;
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) start();
   else                                    CheckForClose();
//---
  }
//+------------------------------------------------------------------+
