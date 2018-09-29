
interface StockInterface {
  RequestResponse: 
  				   richiestaDisponibilitaOro(void)(double),
  				   richiestaDisponibilitaGrano(void)(double),
  				   richiestaDisponibilitaPetrolio(void)(double),

  				   inviaStockMarket(string)(void), 
  				   stampaStock(void)(string),

  				   deperisciStockOro(void)(string),
             deperisciStockGrano(void)(string),
             deperisciStockPetrolio(void)(string),
             
             incrementaStockOro(void)(string),
             incrementaStockGrano(void)(string),
             incrementaStockPetrolio(void)(string)
  				   

}