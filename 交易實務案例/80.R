#取得即時報價，詳細在技巧51
source("function.R")

#設定初始倉位，若為0則為無在倉部位
index <- 0
#設定趨勢，1為做多、-1則為做空
trend <- 1

#設定變數初始格式
MAarray <- numeric(0)
MAnum <- 10
lastHMTime <- 0
lastPrice <- 0 
lastMAValue <- 0

while(index ==0 ){

 #取得即時成交資訊
 Mdata<-GetMatchData(DataPath,Date)
 MatchPrice <- as.numeric(Mdata[[1]][2])
 HMTime <- as.numeric(paste0(substr(Mdata[[1]][1],1,2),substr(Mdata[[1]][1],4,5)))

 #更新MA Array
 if(length(MAarray)==0){
  MAarray <- c(MatchPrice,MAarray[1:(MAnum-1)])
  lastHMTime <- HMTime
  next
 }else if (HMTime==lastHMTime){
  MAarray[1] <- MatchPrice
 }else if(HMTime>lastHMTime){    
  MAarray <- c(MatchPrice,MAarray[1:(MAnum-1)])
  lastHMTime <- HMTime
 }
 #當MA滿足10分鐘的資料時，才進行進場判斷
 if(length(na.omit(MAarray))==MAnum){
  #計算MA值
  MAValue <- round(mean(MAarray),2)
  #若沒有前一筆資訊，則無法進行MA穿越判斷
  if (lastMAValue == 0 ){
   lastMAValue <- MAValue
   lastPrice <- MatchPrice
   next
  } 
  #進行判斷，本範例趨勢預設為1，
  if(trend==1){
   if(lastPrice <= lastMAValue & MatchPrice > MAValue){
    index <- 1
    print("Order Buy Success!")
    break
   }
  }else if(trend==(-1)){
   if(lastPrice >= lastMAValue & MatchPrice < MAValue){
    index <- (-1)
    print("Order Sell Success!")
    break
   }
  }
  #更新最新值
  lastPrice <- MatchPrice
  lastMAValue <- MAValue
 }

}

#接著以下為出場條件判斷，本章不做介紹