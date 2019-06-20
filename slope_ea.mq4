//+------------------------------------------------------------------+
//|                                                     slope_ea.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| HMA.mq4 
//| Copyright © 2006 WizardSerg <wizardserg@mail.ru>, ?? ??????? ForexMagazine #104 
//| wizardserg@mail.ru 
//| Revised by IgorAD,igorad2003@yahoo.co.uk |   
//| Personalized by iGoR AKA FXiGoR for the Trend Slope Trading method (T_S_T) 
//| Link: 
//| contact: thefuturemaster@hotmail.com                                                                         
//+------------------------------------------------------------------+


//---- input parameters 
extern int       period=80; 
extern int       method=3;                         // MODE_SMA 
extern int       price=0;

#define MAGICMA  201                          // PRICE_CLOSE 
//---- buffers 
double Uptrend[];
double Dntrend[];
;
double ExtMapBuffer[];
bool selorder, buyorder;
double vect[], trend[];
 int x = 0;
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
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 

int OnInit() 
{ 
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
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
//| ?????????? ???????                                               | 
//+------------------------------------------------------------------+ 
double WMA(int y, int p) 
{ 
    return(iMA(NULL, 0, p, 0, method, price, y));    
} 

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start() 
{ 
int res;
int counted_bars;
counted_bars = Bars - 1;

 if(counted_bars < 0)
       return(-1);
//---- the last calculated bar must be recalculated 
   if(counted_bars > 0) 
       counted_bars--;
 
if(Volume[0]>1) return (0);
 if(counted_bars < 0) 
        return(-1); 
                  
    
    int p = MathSqrt(period);              
    int e = Bars - counted_bars + period + 1; 
    
    //double vect[], trend[]; 
    /////////////////////////////////////////////////
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
  
  if(Ask < p)
  {takeprofit1 = NormalizeDouble(p,_Digits)};
  else if((Ask>p) && (Ask < r1)&& (Ask <r2))
  {takeprofit1 = NormalizeDouble(r1,_Digits)};
  else if((Ask>p)&&(Ask>r1)&&(Ask<r2))
  {takeprofit1 = NormalizeDouble(r1,_Digits)};
  
  if(Bid > s1)
  {takeprofit2 = NormalizeDouble(s1,_Digits) }
  else if((Bid <s1)&&(Bid > s2))
  {takeprofit2 = NormalizeDouble(s2,_Digits) }
  
  ////////////////////////////////////////////////////////////
  
 
    if(e > Bars) 
        e = Bars;    
 ArrayResize(Uptrend,e); 
   ArraySetAsSeries(Uptrend, true); 
   ArrayResize(Dntrend,e); 
    ArraySetAsSeries(Dntrend, true); 
     ArrayResize(ExtMapBuffer,e); 
    ArraySetAsSeries(ExtMapBuffer, true);
    ArrayResize(vect, e); 
    ArraySetAsSeries(vect, true);
    ArrayResize(trend, e); 
    ArraySetAsSeries(trend, true); 
    
    for(x = 0; x < e; x++) 
    { 
        vect[x] = 2*WMA(x, period/2) - WMA(x, period);        
 //       Print("Bar date/time: ", TimeToStr(Time[x]), " close: ", Close[x], " vect[", x, "] = ", vect[x], " 2*WMA(p/2) = ", 2*WMA(x, period/2), " WMA(p) = ",  WMA(x, period)); 
    } 

    for(x = 0; x < e-period; x++)
     
        ExtMapBuffer[x] = iMAOnArray(vect, 0, p, 0, method, x);        
    
   for(x = e-period; x >= 0; x--)
    {     
        trend[x] = trend[x+1];
        if (ExtMapBuffer[x]> ExtMapBuffer[x+1]) trend[x] =1;
        if (ExtMapBuffer[x]< ExtMapBuffer[x+1]) trend[x] =-1;
    
    if (trend[x]>0)
    { Uptrend[x] = ExtMapBuffer[x]; 
      if (trend[x+1]<0) Uptrend[x+1]=ExtMapBuffer[x+1];
     
      res = OrderSend(Symbol(),OP_BUY,1,Ask,3,0,takeprofit1,"My order",MAGICMA,0,Blue);
    }
    else              
    if (trend[x]<0)
    { 
      Dntrend[x] = ExtMapBuffer[x]; 
      if (trend[x+1]>0) Dntrend[x+1]=ExtMapBuffer[x+1];
    
         res=OrderSend(Symbol(),OP_SELL,1,Bid,3,0,takeprofit2,"My order",MAGICMA,0,Red);
    }       
    
    //Print( " trend=",trend[x]);
    }
    return 0;
}
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void CheckForClose()
  {
  // double ma;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1){ return;}
//--- get Moving Average 
  // ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(trend[x]<0)
           {
          
           if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         // if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
           //Print("OrderModify error ",GetLastError());
         if(trend[x]>0)
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
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0)
  start();
  else
  CheckForClose();
  }
//+------------------------------------------------------------------+
