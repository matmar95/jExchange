include "StockInterface.iol"
include "MarketInterface.iol"
include "console.iol"
include "time.iol"
include "math.iol"
include "semaphore_utils.iol"


inputPort Stock {
	Location: "socket://localhost:8002"
	Protocol: sodep	
	Interfaces: StockInterface
}

outputPort MarketService {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: MarketInterface
}

//inputPort per la gestione del Timer
inputPort TimerPort {
	Location: "local"
	OneWay: incrementoOro( string), 
          incrementoGrano(string), 
          decrementoGrano(string),
          incrementoPetrolio(string), 
          decrementoPetrolio(string)
}

//mini costrutto per inizializzare i Timer
type MyTimerType: double {
  .operation: string
  .message: undefined
}
//outputPort per inviare il nuovo incr/decr al Timer
outputPort MyTimer {
  OneWay: setNextTimeout( MyTimerType )
}
//importo la classe MyTimer.java 
embedded {
  Java: "MyTimer" in MyTimer
}

//Metodo per stampare gli stock una volta creati
define stampaStock
{
  println@Console( "STOCK:\n************************" )();
  foreach ( Value : global.StockStructure ) {
      println@Console( "|" + global.StockStructure.Value[iStock].name + 
      " |\n|Disponibilità: " + global.StockStructure.Value[iStock].available + 
      " |\n|Prezzo: " + global.StockStructure.Value[iStock].price +" |"  )();
      println@Console("************************")();
      iStock++
  }  
}

//METODO LETTORI DELLA DISPONIBILITA DELL' ORO
define startLetturaDispOro {
  acquire@SemaphoreUtils(mutexLetturaDispOro)(sResponse);
  global.contatoreLettoriOro++;
  if( global.contatoreLettoriOro == 1 ) {
    acquire@SemaphoreUtils(semAvailableOro)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaDispOro)(sResponse)  
}

define endLetturaDispOro
{
  acquire@SemaphoreUtils(mutexLetturaDispOro)(sResponse);
  global.contatoreLettoriOro--;
  if(global.contatoreLettoriOro == 0){
    release@SemaphoreUtils(semAvailableOro)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaDispOro)(sResponse)
}


//METODO LETTORI DELLA DISPONIBILITA DEL GRANO
define startLetturaDispGrano {
  acquire@SemaphoreUtils(mutexLetturaDispGrano)(sResponse);
  global.contatoreLettoriGrano++;
  if( global.contatoreLettoriGrano == 1 ) {
    acquire@SemaphoreUtils(semAvailableGrano)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaDispGrano)(sResponse)  
}

define endLetturaDispGrano
{
  acquire@SemaphoreUtils(mutexLetturaDispGrano)(sResponse);
  global.contatoreLettoriGrano--;
  if(global.contatoreLettoriGrano == 0){
    release@SemaphoreUtils(semAvailableGrano)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaDispGrano)(sResponse)
}

//METODO LETTORI DELLA DISPONIBILITA DEL PETROLIO
define startLetturaDispPetrolio {
  acquire@SemaphoreUtils(mutexLetturaDispPetrolio)(sResponse);
  global.contatoreLettoriPetrolio++;
  if( global.contatoreLettoriPetrolio == 1 ) {
    acquire@SemaphoreUtils(semAvailablePetrolio)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaDispPetrolio)(sResponse)  
}

define endLetturaDispPetrolio
{
  acquire@SemaphoreUtils(mutexLetturaDispPetrolio)(sResponse);
  global.contatoreLettoriPetrolio--;
  if(global.contatoreLettoriPetrolio == 0){
    release@SemaphoreUtils(semAvailablePetrolio)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaDispPetrolio)(sResponse)
}

init
{ 
  //CREAZIONE STOCK ORO
  Stocks.name = "ORO";
  Stocks.available = double("5");
  Stocks.price = double("25");
  creaStock@MarketService(Stocks)(global.StockStructure);
  visibleOro = true;
  oroTrue@MarketService(visibleOro)();
  stampaStock;
  sleep@Time(500)();

  //CREAZIONE STOCK GRANO
  Stocks.name = "GRANO";
  Stocks.available = double("100");
  Stocks.price = double("100");
  creaStock@MarketService(Stocks)(global.StockStructure);
  visibleGrano = true;
  granoTrue@MarketService(visibleGrano)();
  stampaStock;
  sleep@Time(500)();
  
  //CREAZIONE STOCK PETROLIO
  Stocks.name = "PETROLIO";
  Stocks.available = double("50");
  Stocks.price = double("75");
  creaStock@MarketService(Stocks)(global.StockStructure);
  visiblePetrolio = true;
  petrolioTrue@MarketService(visiblePetrolio)();
  stampaStock;
  sleep@Time(500)();

  //Inizializzazione dei Timer per l'incremento e decremento degli Stock,
  //in cui il primo valore rappresenta i millisec che intercorre tra un
  //incremento/decremento dello Stock e il successivo
	incrementoOro = 10000;
    with( incrementoOro ){
      .operation = "incrementoOro";
      .message = "Oro"
    };

  incrementoGrano = 3000;
    with( incrementoGrano ){
      .operation = "incrementoGrano";
      .message = "Grano"
    };

  decrementoGrano = 5000;
    with( decrementoGrano ){
      .operation = "decrementoGrano";
      .message = "Grano"
    };

  
  incrementoPetrolio = 10000;
    with( incrementoPetrolio ){
      .operation = "incrementoPetrolio";
      .message = "Petrolio"
    };

  decrementoPetrolio = 8000;
    with( decrementoPetrolio ){
      .operation = "decrementoPetrolio";
      .message = "Petrolio"
    };
  //Gestione dei Timeout paralleli che arrivano nello stesso istante
  { setNextTimeout@MyTimer( incrementoOro )|
    setNextTimeout@MyTimer( decrementoGrano ) |
    setNextTimeout@MyTimer( incrementoGrano ) |
    setNextTimeout@MyTimer( decrementoPetrolio ) |
    setNextTimeout@MyTimer( incrementoPetrolio ) };

//INIZIALIZZAZIONE DEI SEMAFORI 
semAvailableOro.name ="Semaforo disponibilità Oro";
release@SemaphoreUtils(semAvailableOro)(sResponse);

semAvailableGrano.name ="Semaforo disponibilità Grano";
release@SemaphoreUtils(semAvailableGrano)(sResponse);

semAvailablePetrolio.name ="Semaforo disponibilità Petrolio";
release@SemaphoreUtils(semAvailablePetrolio)(sResponse);

mutexLetturaDispOro.name ="Semaforo disponibilità oro";
release@SemaphoreUtils(mutexLetturaDispOro)(sResponse);

mutexLetturaDispGrano.name ="Semaforo disponibilità Grano";
release@SemaphoreUtils(mutexLetturaDispGrano)(sResponse);

mutexLetturaDispPetrolio.name ="Semaforo disponibilità Petrolio";
release@SemaphoreUtils(mutexLetturaDispPetrolio)(sResponse);

//variabili per i contatori Lettori di ogni Stock
global.contatoreLettoriOro = 0;
global.contatoreLettoriGrano = 0;
global.contatoreLettoriPetrolio = 0

}

execution{ concurrent }

main
{   
  //Input choice per incrementare lo Stock Oro
	[ incrementoOro( respost ) ]{
    //Calcolo il val random di incremento
    min = 0;
    max = 2;
    random@Math()(valIncremento);
    valIncremento = int(valIncremento*(max-min+1)+min);
    val1 = double(valIncremento);
    //Acquisisco il LOCK sul Semaforo Disponibilità Oro
    acquire@SemaphoreUtils(semAvailableOro)(sResponse);
    val2 = double(global.StockStructure.Value[0].available); 
    if( val2 !=0 ) {
      rapportoPrezzo = (val1)/(val2);
      //Aggiorno la disponibilità Oro in StockStructure del nuovo incremento 
      global.StockStructure.Value[0].available = global.StockStructure.Value[0].available + valIncremento;
      //Invio il rapporto Incremento al Market
      inviaIncrementoOro@MarketService(rapportoPrezzo)()
      
    }else{
      global.StockStructure.Value[0].available = global.StockStructure.Value[0].available + valIncremento;
      //Invio al Market un incremento zero poichè la Disp precedente era nulla
      inviaIncrementoOro@MarketService(0)()
      
    };
    println@Console( "| STOCK "+global.StockStructure.Value[0].name +" |\n| + " + rapportoPrezzo + " |\n| Available: " +
                       global.StockStructure.Value[0].available +"   ↑" + valIncremento +" |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableOro)(sResponse);
    //Richiamo la OneWay setNextTimeout per consentire il nuovo Incremento
    setNextTimeout@MyTimer( incrementoOro )
  }

  //Input choice per incrementare lo Stock Grano
  [incrementoGrano(respost)]{
    //Calcolo il val random di incremento
    min = 3;
    max = 6;
    random@Math()(valIncremento);
    valIncremento = int(valIncremento*(max-min+1)+min);
    val1 = double(valIncremento);
    //Acquisisco il LOCK sul Semaforo Disponibilità Grano
    acquire@SemaphoreUtils(semAvailableGrano)(sResponse);
    val2 = double(global.StockStructure.Value[1].available);

    if( val2!=0 ) {
      rapportoPrezzo = (val1)/(val2);
      //Aggiorno la disponibilità Grano in StockStructure con il nuovo Incremento
      global.StockStructure.Value[1].available = global.StockStructure.Value[1].available + valIncremento;
      //Invio il rapporto incremento al Market
      inviaIncrementoGrano@MarketService(rapportoPrezzo)()
      
    }else{
      global.StockStructure.Value[1].available = global.StockStructure.Value[1].available + valIncremento;
      //Invio al Market un incremento zero poichè la Disp precedente era nulla
      inviaIncrementoGrano@MarketService(0)()
    };

    println@Console( "| STOCK "+global.StockStructure.Value[1].name +" |\n| + " + rapportoPrezzo + " |\n| Available: " +
                       global.StockStructure.Value[1].available +"   ↑" + valIncremento + "|\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableGrano)(sResponse);
    //Richiamo la OneWay setNextTimeout per consentire il nuovo Incremento
    setNextTimeout@MyTimer( incrementoGrano )
  }

  //Input choice per decrementare lo Stock Grano
  [decrementoGrano( respost ) ]{
    //Calcolo il val Random di decremento
    min = 1;
    max = 5;
    random@Math()(valDecremento);
    valDecremento = int(valDecremento*(max-min+1)+min);
    val1 = double(valDecremento);
    //Acquisisco il LOCK sul Semaforo Disponibilità Grano
    acquire@SemaphoreUtils(semAvailableGrano)(sResponse);
    val2 = double(global.StockStructure.Value[1].available);

    if( (val2-val1)>0 ) {
      rapportoPrezzo = (val1)/(val2); 
      //Aggiorno la disponibilità Grano    
      global.StockStructure.Value[1].available = global.StockStructure.Value[1].available - valDecremento;
      inviaDecrementoGrano@MarketService(rapportoPrezzo)()
      
    }else{
      //Se il val di Decremento genera una Disp negativa la setto a zero
      global.StockStructure.Value[1].available = 0;
      //Invio al Market il decremento zero
      inviaDecrementoGrano@MarketService(0)()
    };

    println@Console( "| STOCK "+global.StockStructure.Value[1].name +" |\n| - " + rapportoPrezzo + " |\n| Available: " +
                       global.StockStructure.Value[1].available +"   ↓" + valDecremento + " |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableGrano)(sResponse);
    //Richiamo la OneWay setNextTimeout per consentire il nuovo Decremento
    setNextTimeout@MyTimer( decrementoGrano)
  } 

  //Input choice per incrementare lo Stock Petrolio
  [incrementoPetrolio(respost)]{
    //Calcolo il val Random di incremento
    min = 1;
    max = 3;
    random@Math()(valIncremento);
    valIncremento = int(valIncremento*(max-min+1)+min);
    val1 = double(valIncremento);
    //Acquisisco il LOCK sul Semaforo Disponibilità Petrolio
    acquire@SemaphoreUtils(semAvailablePetrolio)(sResponse);
    val2 = double(global.StockStructure.Value[2].available);

    if( val2 !=0 ) {
      rapportoPrezzo = (val1)/(val2);
      //Aggiorno la disponibilità sulla StockStructure
      global.StockStructure.Value[2].available = global.StockStructure.Value[2].available + valIncremento;
      inviaIncrementoPetrolio@MarketService(rapportoPrezzo)()
      

    }else{
      global.StockStructure.Value[2].available = global.StockStructure.Value[2].available + valIncremento;
      //Invio un rapporo Incremento pari a zero se la disp precedente era nulla
      inviaIncrementoPetrolio@MarketService(0)()
    };

    println@Console( "| STOCK "+global.StockStructure.Value[2].name +" |\n| + " + rapportoPrezzo + " |\n| Available: " +
                       global.StockStructure.Value[2].available +"   ↑" + valIncremento + " |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailablePetrolio)(sResponse);
    //Richiamo la OneWay setNextTimeout per consentire il nuovo Incremento
    setNextTimeout@MyTimer( incrementoPetrolio )
  }

  //Input choice per decrementare lo Stock Petrolio
  [decrementoPetrolio(respost) ]{
    //Calcolo il val Random di decremento
    min = 1;
    max = 2;
    random@Math()(valDecremento);
    valDecremento = int(valDecremento*(max-min+1)+min);
    val1 = double(valDecremento);
    //Acquisisco il LOCK sul Semaforo Disponibilità Petrolio
    acquire@SemaphoreUtils(semAvailablePetrolio)(sResponse);
    val2 = double(global.StockStructure.Value[2].available);

    if( (val2-val1)>0 ) {
      rapportoPrezzo = (val1)/(val2);
      //Aggiorno la disponibilità nella StockStructure
      global.StockStructure.Value[2].available = global.StockStructure.Value[2].available - valDecremento;
      inviaDecrementoPetrolio@MarketService(rapportoPrezzo)()
    }else{
      //Se il val di Decremento genera una Disp negativa la setto a zero
      global.StockStructure.Value[2].available = 0;
      //Invio al Market il decremento zero
      inviaDecrementoPetrolio@MarketService(0)()
    };

    println@Console( "| STOCK "+global.StockStructure.Value[2].name +" |\n| - " + rapportoPrezzo + 
    " |\n| Available: " + global.StockStructure.Value[2].available +"   ↓" + valDecremento + " |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailablePetrolio)(sResponse);
    //Richiamo la OneWay setNextTimeout per consentire il nuovo Decremento
    setNextTimeout@MyTimer( decrementoPetrolio)
  } 

  //Input choice per la richiesta Della DisponibilitàOro da parte del Market
  [richiestaDisponibilitaOro()(respost){
    //Acquisisco il MUTEX per la lettura
    startLetturaDispOro;
    respost = double(global.StockStructure.Value[0].available);
    //Rilascio il MUTEX a lettura terminata
    endLetturaDispOro
  }] 

  //Input choice per la richiesta Della DisponibilitàGrano da parte del Market
  [richiestaDisponibilitaGrano()(respost){
    //Acquisisco il MUTEX per la lettura
    startLetturaDispGrano;
    respost = double(global.StockStructure.Value[1].available);
    //Rilascio il MUTEX a lettura terminata
    endLetturaDispGrano
  }]

  //Input choice per la richiesta Della DisponibilitàPetrolio da parte del Market
  [richiestaDisponibilitaPetrolio()(respost){
    //Acquisisco il MUTEX per la lettura
    startLetturaDispPetrolio;
    respost = global.StockStructure.Value[2].available;
    //Rilascio il MUTEX a lettura terminata
    endLetturaDispPetrolio
  }]

  //Input choice di deperimento Stock Oro a seguito di un acquisto
  [deperisciStockOro()(respost){
    //Acquisisco il LOCK sul Semaforo Disponibilità Oro
    acquire@SemaphoreUtils(semAvailableOro)(sResponse);
    global.StockStructure.Value[0].available--;
    println@Console( "| AGGIORNAMENTO STOCK DOPO ACQUISTO |\n| " + global.StockStructure.Value[0].name + 
                     " |\n| Disponibilità: " + global.StockStructure.Value[0].available +"|\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    respost = "Stock " + global.StockStructure.Value[0].name + " decrementato";
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableOro)(sResponse)
  }]
  
  //Input choice di deperimento Stock Grano a seguito di un acquisto
  [deperisciStockGrano()(respost){
    //Acquisisco il LOCK sul Semaforo Disponibilità Grano
    acquire@SemaphoreUtils(semAvailableGrano)(sResponse);
    global.StockStructure.Value[1].available--;
    println@Console( "| AGGIORNAMENTO STOCK DOPO ACQUISTO |\n| " + global.StockStructure.Value[1].name + 
                     " |\n| Disponibilità: " + global.StockStructure.Value[1].available+" |\n°°°°°°°°°°°°°°°°°°°°°°\n")();       
    respost = "Stock " + global.StockStructure.Value[1].name + " decrementato";
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableGrano)(sResponse) 
  }]
  
  //Input choice di deperimento Stock Petrolio a seguito di un acquisto
  [deperisciStockPetrolio()(respost){
    //Acquisisco il LOCK sul Semaforo Disponibilità Petrolio
    acquire@SemaphoreUtils(semAvailablePetrolio)(sResponse);
    global.StockStructure.Value[2].available--;
    println@Console( "| AGGIORNAMENTO STOCK DOPO ACQUISTO |\n| " + global.StockStructure.Value[2].name + 
                     " |\n| Disponibilità: " + global.StockStructure.Value[2].available+" |\n°°°°°°°°°°°°°°°°°°°°°°\n")(); 
    respost = "Stock " + global.StockStructure.Value[2].name + " decrementato";
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailablePetrolio)(sResponse)
  }]
  
  //Input choice di incremento Stock Oro a seguito di una vendita
  [incrementaStockOro()(respost){
    //Acquisisco il LOCK sul Semaforo Disponibilità Oro
    acquire@SemaphoreUtils(semAvailableOro)(sResponse);
    global.StockStructure.Value[0].available++;
    println@Console( "| AGGIORNAMENTO STOCK DOPO VENDITA |\n| " + global.StockStructure.Value[0].name + 
                     "|\n| Disponibilità: " + global.StockStructure.Value[0].available +" |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    respost = "Stock " + global.StockStructure.Value[0].name + " decrementato";
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableOro)(sResponse)
  }]

  //Input choice di incremento Stock Grano a seguito di una vendita
  [incrementaStockGrano()(respost){
    //Acquisisco il LOCK sul Semaforo Disponibilità Grano
    acquire@SemaphoreUtils(semAvailableGrano)(sResponse);
    global.StockStructure.Value[1].available++;
    println@Console( "| AGGIORNAMENTO STOCK DOPO VENDITA |\n| " + global.StockStructure.Value[1].name + 
                     "|\n| Disponibilità: " + global.StockStructure.Value[1].available +" |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    respost = "Stock " + global.StockStructure.Value[1].name + " decrementato";
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailableGrano)(sResponse)
  }]

  //Input choice di incremento Stock Petrolio a seguito di una vendita
  [incrementaStockPetrolio()(respost){
    //Acquisisco il LOCK sul Semaforo Disponibilità Petrolio
    acquire@SemaphoreUtils(semAvailablePetrolio)(sResponse);
    global.StockStructure.Value[2].available++;
    println@Console( "| AGGIORNAMENTO STOCK DOPO VENDITA |\n| " + global.StockStructure.Value[2].name + 
                     " |\n| Disponibilità: " + global.StockStructure.Value[2].available +" |\n°°°°°°°°°°°°°°°°°°°°°°\n")();
    respost = "Stock " + global.StockStructure.Value[2].name + " incrementato";
    //Rilascio il LOCK
    release@SemaphoreUtils(semAvailablePetrolio)(sResponse)
  }]
}
