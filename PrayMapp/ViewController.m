//
//  ViewController.m
//  PrayMapp
//
//  Created by Marco Guevara on 21/04/14.
//  Copyright (c) 2014 Wapps. All rights reserved.
//

#import "ViewController.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"


@interface ViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CrumbPath *crumbs;
@property (nonatomic, strong) CrumbPathView *crumbView;
@property (nonatomic, strong) CrumbPathView *crumbView2;
@property (nonatomic,retain) NSString *descripcionRuta;
@property (nonatomic, assign) Action currentAction;
@end

@implementation ViewController

@synthesize tracking;
@synthesize descripcionRuta;
@synthesize currentAction;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Note: we are using Core Location directly to get the user location updates.
    // We could normally use MKMapView's user location update delegation but this does not work in
    // the background.  Plus we want "kCLLocationAccuracyBestForNavigation" which gives us a better accuracy.
    //
    
    totalGrupos = 0;
    totalRutas = 0;
    
    //[self mostrarGrupos];
    
    [self.progressView setProgress:0];
    
    tracking = NO;
    
    currentAction = MOSTRAR_GRUPOS;
    //[self.progressView setProgress:0.75];
    
    [self.map setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; // Tells the location manager to send updates to this object
    self.map.delegate =self;
    
    self.map.showsUserLocation = YES;
    
    //[self.map setMapType:MKMapTypeHybrid];
    //[self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    // By default use the best accuracy setting (kCLLocationAccuracyBest)
	//
	// You mau instead want to use kCLLocationAccuracyBestForNavigation, which is the highest possible
	// accuracy and combine it with additional sensor data.  Note that level of accuracy is intended
	// for use in navigation applications that require precise position information at all times and
	// are intended to be used only while the device is plugged in.
    //
    //BOOL navigationAccuracy = [self.toggleNavigationAccuracyButton isOn];
    BOOL navigationAccuracy = YES;
	self.locationManager.desiredAccuracy =
    (navigationAccuracy ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyBest);
    
    // hide the prefs UI for user tracking mode - if MKMapView is not capable of it
    /*if (![self.map respondsToSelector:@selector(setUserTrackingMode:animated:)])
     {
     self.trackUserButton.hidden = self.trackUserLabel.hidden = YES;
     }*/
    //[self performSelectorOnMainThread:@selector(locationManager) withObject:nil waitUntilDone:NO];
    [self.locationManager startUpdatingLocation];
    // On the first location update only, zoom map to user location
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 2000, 2000);
    [self.map setRegion:region animated:YES];
    
    if(arrayRutaCoord == nil){
        arrayRutaCoord = [[NSMutableArray alloc] init];
    }
    if(id_rutas == nil){
        id_rutas = [[NSMutableArray alloc] init];
    }
    //[self getGrupos];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

#pragma mark - MapKit

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{

    if (newLocation)
    {
        /*if ([self.toggleAudioButton isOn])
         {
         [self setSessionActiveWithMixing:YES]; // YES == duck if other audio is playing
         [self playSound];
         }*/
        
        
        // On the first location update only, zoom map to user location
        /*MKCoordinateRegion region =
         MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
         [self.map setRegion:region animated:YES];
         NSLog(@"Latitud inicial: %f Longitud inicial: %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);*/
        
		// make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            
            if (!self.crumbs)
            {
                // This is the first time we're getting a location update, so create
                // the CrumbPath and add it to the map.
                //
                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.map addOverlay:self.crumbs level:MKOverlayLevelAboveLabels];
                
                // On the first location update only, zoom map to user location
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.map setRegion:region animated:YES];
                NSLog(@"first Latitud: %f Longitud: %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                
                
                //MKCircle *circle = [MKCircle circleWithCenterCoordinate:newLocation.coordinate radius:1000];
                //[self.map addOverlay:circle level:MKOverlayLevelAboveLabels];
            }
            else
            {
                // This is a subsequent location update.
                // If the crumbs MKOverlay model object determines that the current location has moved
                // far enough from the previous location, use the returned updateRect to redraw just
                // the changed area.
                //
                // note: iPhone 3G will locate you using the triangulation of the cell towers.
                // so you may experience spikes in location data (in small time intervals)
                // due to 3G tower triangulation.
                //
                if (tracking) {
                    //float latitud = newLocation.coordinate.latitude;
                    //float longitud = newLocation.coordinate.longitude;
                    temp_Latitud = [NSString stringWithFormat: @"%f", newLocation.coordinate.latitude];
                    temp_Longitud = [NSString stringWithFormat: @"%f", newLocation.coordinate.longitude];
                    NSLog(@"Tracking - Latitud: %@ Longitud: %@",temp_Latitud,temp_Longitud);
                    
                    [arrayRutaCoord addObject:[NSDictionary dictionaryWithObjectsAndKeys:temp_Latitud,@"Latitud",temp_Longitud,@"Longitud",nil]];
                    
                    MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                    //[self InsertRutaCoord:7 :newLocation.coordinate.latitude :newLocation.coordinate.latitude];
                    
                    
                    //[arrayRutaCoord addObject:[NSDictionary dictionaryWithObjectsAndKeys:IdRuta,@"IdRuta",newLocation.coordinate.latitude,@"Latitud",newLocation.coordinate.longitude,@"Longitud",nil]];
                    if (!MKMapRectIsNull(updateRect))
                    {NSLog(@"XDLOL");
                        // There is a non null update rect.
                        // Compute the currently visible map zoom scale
                        MKZoomScale currentZoomScale = (CGFloat)(self.map.bounds.size.width / self.map.visibleMapRect.size.width);
                        // Find out the line width at this zoom scale and outset the updateRect by that amount
                        CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                        updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                        // Ask the overlay view to update just the changed area.
                        [self.crumbView setNeedsDisplayInMapRect:updateRect];
                        //[self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse1 count:pointsCount1] level:MKOverlayLevelAboveRoads];
                    }
                }
            }
        }
    }
    
}
/*
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    
    
    
    return self.crumbView;
}
*/

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {

    NSLog(@" overlay %@",[overlay class]);
    if([overlay isKindOfClass:MKPolyline.class])
    {
        //NSLog(@"isclass polyline");
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithOverlay:overlay];
        //lineView.strokeColor = [UIColor blueColor];
        lineView.strokeColor = pathColor;
        return lineView;
    }
    else
    {
        
        if (!self.crumbView)
        {NSLog(@"isclass crumbpath");
            _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
        }
        return self.crumbView;
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Index button: %ld", (long)buttonIndex);
    NSString *descripcion = [[alertView textFieldAtIndex:0] text];
    
    if(buttonIndex == 1){
        if(alertView.tag == 0)
        {
            /*UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(switchTracking:)];
             stop.style = UIBarButtonItemStyleBordered;
             self.toolBar.items = [NSArray arrayWithObject:stop];*/
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = self.locationManager.location.coordinate;
            point.title = @"Inicio de Ruta";
            point.subtitle = descripcion;
            
            [self.map addAnnotation:point];
            
            DescInicio = descripcion;
            latitudInicial = point.coordinate.latitude;
            longitudInicial = point.coordinate.longitude;
            //[self limpiar];
            [self.locationManager startUpdatingLocation];
            tracking = YES;
            [self.statusIndicator setTitle:@"Creando Ruta..."];
        }
        else if (alertView.tag == 1)
        {
            /*UIBarButtonItem *start = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(switchTracking:)];
             start.style = UIBarButtonItemStyleBordered;
             self.toolBar.items = [NSArray arrayWithObject:start];*/
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = self.locationManager.location.coordinate;
            point.title = @"Fin de Ruta";
            point.subtitle = descripcion;//CLLocationCoordinate2DMake(51.49795, -0.174056);
            [self.map addAnnotation:point];
            
            [self.statusIndicator setTitle:@"Listo"];
            
            [self InsertRuta:DescInicio :descripcion :latitudInicial :longitudInicial :point.coordinate.latitude :point.coordinate.longitude];
            
            NSLog(@"Ruta coord count %lu",(unsigned long)arrayRutaCoord.count);
            
            [self getLastRuta];
            
            tracking = NO;
        }
        else if (alertView.tag == 2)
        {
            [self InsertGrupo:descripcion :self.locationManager.location.coordinate.latitude :self.locationManager.location.coordinate.longitude];
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = self.locationManager.location.coordinate;
            point.title = @"Grupo";
            point.subtitle = descripcion;
            [self.map addAnnotation:point];
        }
    }
}

-(void)InsertRuta:(NSString *)DescInicio :(NSString *)DescFin
                 :(double)LatitudInicio :(double)LongitudInicio
                 :(double)LatitudFin :(double)LongitudFin
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/InsertRuta.php"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"DescInicio=%@&DescFin=%@&LatitudInicio=%f&LongitudInicio=%f&LatitudFin=%f&LongitudFin=%f",
                       DescInicio,
                       DescFin,LatitudInicio,LongitudInicio,LatitudFin,LongitudFin] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [[NSError alloc] init];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

- (void)getGrupos {
    //[self.activityIndicator startAnimating];
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/getGrupo.php"];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        totalGrupos = grupos.count;
        NSLog(@"Total grupos: %lu",(unsigned long)totalGrupos);
    }
    else
    {
    }
}

- (void)getLastRuta {
    //[self.activityIndicator startAnimating];
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/getLastRuta.php"];
	currentAction = LAST_RUTA;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        NSLog(@"Total rutas: %lu",(unsigned long)receivedData.length);
    }
    else
    {
    }
}

- (void)getRutas {
    //[self.activityIndicator startAnimating];
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/getRuta.php"];
	currentAction = ALL_RUTAS;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        totalRutas = receivedData.length;
        NSLog(@"Total rutas: %lu",(unsigned long)totalRutas);
    }
    else
    {
    }
}

-(NSString *)getLastIdRuta{
    NSString *lastIdRuta = @"-1";
    if(rutas.count>0){
        NSDictionary *lastRuta = (NSDictionary *)[rutas objectAtIndex:0];
        lastIdRuta = [lastRuta objectForKey:@"IdRuta"];
        NSLog(@"Last id ruta: %@",lastIdRuta);
    }
    return lastIdRuta;
}

- (void)getRutaCoord {
    //[self.activityIndicator startAnimating];
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/getRutaCoord.php"];
    
	currentAction = TRAZAR_COORDENADAS;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        //NSLog(@"Total coordenadas: %lu",(unsigned long)receivedData.length);
    }
    else
    {
    }
}

- (void)getRutaCoord:(int)Id_Ruta {
    //[self.activityIndicator startAnimating];
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/getRutaCoord.php?IdRuta=%d",Id_Ruta];
    
	currentAction = TRAZAR_COORDENADAS;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        //NSLog(@"Total coordenadas: %lu",(unsigned long)receivedData.length);
    }
    else
    {
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"data: %@",data);
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"finished connection url: %@",connection);
	//if (chatParser)
    //  [chatParser release];
	
	if ( grupos == nil )
		grupos = [[NSMutableArray alloc] init];
    
    if ( rutas == nil )
		rutas = [[NSMutableArray alloc] init];
    
    
	xmlParser = [[NSXMLParser alloc] initWithData:receivedData];
	[xmlParser setDelegate:self];
	[xmlParser parse];
    
    if(currentAction == MOSTRAR_GRUPOS)
        [self mostrarGrupos];
    if(currentAction == LAST_RUTA){
        //[self.progressView setUsesThreadedAnimation:YES];
        [self.statusIndicator setTitle:@"Guardando ruta..."];
        [self GuardarRutas];
    }
    if(currentAction == ALL_RUTAS){
        //[self.progressView setUsesThreadedAnimation:YES];
        [self.statusIndicator setTitle:@"Obteniendo rutas..."];
        //[self LoadAllRutas];
        
        /******/
        float progress;
        
        //[self.progressView setProgress:progress];
        //int lastRuta = [[self getLastIdRuta] intValue];
        for(int i=0; i<rutas.count;i++){
            progress = (float)(i+1)/(float)rutas.count;
            //NSLog(@"Progress: %f",progress);
            [self.progressView setProgress:progress animated:YES];
            NSDictionary *ruta = (NSDictionary *)[rutas objectAtIndex:i];
            int idRuta = [[ruta objectForKey:@"IdRuta"] intValue];
            float latitudInicio = [[ruta objectForKey:@"LatitudInicio"] doubleValue];
            float longitudInicio = [[ruta objectForKey:@"LongitudInicio"] doubleValue];
            float latitudFin = [[ruta objectForKey:@"LatitudFin"] doubleValue];
            float longitudFin = [[ruta objectForKey:@"LongitudFin"] doubleValue];
            NSString *descInicio = [ruta objectForKey:@"DescInicio"];
            NSString *descFin = [ruta objectForKey:@"DescFin"];
            NSLog(@"Ruta: %d DescInicio: %@ latitudInicio: %f longitudInicio: %f descFin: %@ latitudFin: %f longitudFin: %f",idRuta,descInicio,latitudInicio,longitudInicio,descFin,latitudFin,longitudFin);
            
            MKPointAnnotation *pointInicio = [[MKPointAnnotation alloc] init];
            pointInicio.coordinate = CLLocationCoordinate2DMake(latitudInicio, longitudInicio);
            pointInicio.title = @"Inicio de Ruta";
            pointInicio.subtitle = descInicio;
            [self.map addAnnotation:pointInicio];
            
            MKPointAnnotation *pointFin = [[MKPointAnnotation alloc] init];
            pointFin.coordinate = CLLocationCoordinate2DMake(latitudFin, longitudFin);
            pointFin.title = @"Fin de Ruta";
            pointFin.subtitle = descFin;
            [self.map addAnnotation:pointFin];
            rutaCoordIdRuta = idRuta;
            //[id_rutas addObject:idRuta];
            
        }
        [self.statusIndicator setTitle:@"Listo"];
        [self.progressView setProgress:0];
        /******/
        //[self callGetRutaCoord];//temp
        //[self getRutaCoord:25];
        //[self.statusIndicator setTitle:@"Obteniendo rutas..."];
        
        /*
        for(int i=0;i<rutas.count;i++)
        {
            [arrayRutaCoord removeAllObjects];
            progress = (float)(i+1)/(float)rutas.count;
            //NSLog(@"Progress: %f",progress);
            [self.progressView setProgress:progress animated:YES];
            NSDictionary *ruta = (NSDictionary *)[rutas objectAtIndex:i];
            int idRuta = [[ruta objectForKey:@"IdRuta"] intValue];
            [self getRutaCoord:idRuta];
        }
         */
        //[self getRutaCoord:34];
        [self getRutaCoord];
        [self.statusIndicator setTitle:@"Listo"];
        [self.progressView setProgress:0];
    }
    if(currentAction == TRAZAR_COORDENADAS){
        //[self.progressView setUsesThreadedAnimation:YES];
        [self.statusIndicator setTitle:@"Trazando rutas..."];
        //[self LoadCoordenadas];
        
        //[self LoadCoordenadasWithOperation];
        
        //[self addRoute];
        
        [self callAddRoute];
        
        [self.statusIndicator setTitle:@"Listo"];
        [self.progressView setProgress:0];
        //[self.progressView setProgress:0 animated:YES];
    }
}
/*
- (void)addRoute {
    
    float progress;
    
    //[self.progressView setProgress:progress];
    //int lastRuta = [[self getLastIdRuta] intValue];
    [self.progressView setProgress:0 animated:YES];
    oldIdRuta = 0;
    
    NSInteger pointsCount = arrayRutaCoord.count;
    
    CLLocationCoordinate2D pointsToUse[pointsCount];
    NSLog(@"Points count %ld",(long)pointsCount);
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int temp_counter = 0;
    NSString *titleRuta;//MKPolyline *myPolyline;
    for(int i = 0; i < pointsCount; i++) {
        temp_counter++;
        progress = (float)(i+1)/(float)arrayRutaCoord.count;
        //NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        
        [tempArray addObject:coord];
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        
        
        NSLog(@"IdRuta: %d",_idRuta);
        NSLog(@"rutacoord_latitud: %f", _latitud);
        NSLog(@"rutacoord_longitud: %f", _longitud);
        //if(_idRuta==39)
        pointsToUse[i] = CLLocationCoordinate2DMake(_latitud,_longitud);
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        //[tempArray addObject:coord];
        
        if(_idRuta != oldIdRuta){
            if(oldIdRuta!=0){
                NSLog(@"CAMBIO!!");
                NSLog(@"Temp counter: %d",temp_counter);
                titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
                //NSLog(@"ID RUTA: %@",titleRuta);
                CLLocationCoordinate2D tempPoints[temp_counter];
                for(int j=0;j<temp_counter;j++)
                {
                    //CLLocationCoordinate2D *temp_point = (__bridge CLLocationCoordinate2D *)[tempArray objectAtIndex:j];
                    NSDictionary *tempcoord = (NSDictionary *)[tempArray objectAtIndex:j];
                    //int _tidRuta = [[tempcoord objectForKey:@"IdRuta"] intValue];
                    float _tlatitud = [[tempcoord objectForKey:@"Latitud"] floatValue];
                    float _tlongitud = [[tempcoord objectForKey:@"Longitud"] floatValue];
                    tempPoints[j] = CLLocationCoordinate2DMake(_tlatitud,_tlongitud);
                    //NSLog(@"j: %d",j);
                    //NSLog(@"IdRuta: %d",_tidRuta);
                    //CLLocationCoordinate2D *temp_point = tempPoints[j];
                    //NSLog(@"temp point: %@", tempPoints[j]);
                    //NSLog(@"t rutacoord_longitud: %f", _tlongitud);
                    //NSLog(@"t rutacoord_latitud: %f", _tlatitud);
                }
                //MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:(CLLocationCoordinate2D *)(tempArray) count:tempArray.count];
                //MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:tempPoints count:temp_counter];
                //myPolyline = [MKPolyline polylineWithCoordinates:tempPoints count:temp_counter];
                //[self.map addOverlay:myPolyline level:MKOverlayLevelAboveRoads];
                //[tempArray removeAllObjects];
                //NSLog(@"temp points count %d",[tempPoints length]);
                [self.map addOverlay:[MKPolyline polylineWithCoordinates:tempPoints count:temp_counter] level:MKOverlayLevelAboveRoads];
            }
            //if(_idRuta == 34) self.crumbView.pathColor = [UIColor redColor];
            //temp_counter = 0;
        }
        
        oldIdRuta = _idRuta;
    }
    NSLog(@"finished adding points");
    //[arrayRutaCoord removeAllObjects];
    NSString *lastChar = [titleRuta substringFromIndex:[titleRuta length] - 1];
    
    
    if([lastChar isEqualToString:@"1"]) pathColor = [UIColor greenColor];
    if([lastChar isEqualToString:@"2"]) pathColor = [UIColor orangeColor];
    if([lastChar isEqualToString:@"3"]) pathColor = [UIColor purpleColor];
    if([lastChar isEqualToString:@"4"]) pathColor = [UIColor blueColor];
    if([lastChar isEqualToString:@"5"]) pathColor = [UIColor redColor];
    if([lastChar isEqualToString:@"6"]) pathColor = [UIColor yellowColor];
    if([lastChar isEqualToString:@"7"]) pathColor = [UIColor grayColor];
    if([lastChar isEqualToString:@"8"]) pathColor = [UIColor magentaColor];
    if([lastChar isEqualToString:@"9"]) pathColor = [UIColor brownColor];
    if([lastChar isEqualToString:@"0"]) pathColor = [UIColor cyanColor];
     
    
    //if([lastChar isEqualToString:@"4"]) pathColor = [UIColor cyanColor];
    //if([lastChar isEqualToString:@"5"]) pathColor = [UIColor yellowColor];
    
    //MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount];
    //[self.map addOverlay:myPolyline level:MKOverlayLevelAboveRoads];

    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount] level:MKOverlayLevelAboveRoads];
    //NSArray *subarray = [tempArray subarrayWithRange:NSMakeRange(0, 286)];
    //[self.map addOverlay:[MKPolyline polylineWithCoordinates:(__bridge CLLocationCoordinate2D *)(subarray) count:286] level:MKOverlayLevelAboveRoads];
}
*/

/*
- (void)addRoute {
    
    float progress;
    
    //[self.progressView setProgress:progress];
    //int lastRuta = [[self getLastIdRuta] intValue];
    [self.progressView setProgress:0 animated:YES];
    oldIdRuta = 0;
    
    NSInteger pointsCount = arrayRutaCoord.count;
    
    CLLocationCoordinate2D pointsToUse1[283];
    NSLog(@"Points count %ld",(long)pointsCount);
    //NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int temp_counter = 0;
    NSString *titleRuta;//MKPolyline *myPolyline;
    for(int i = 0; i < 283; i++) {
        temp_counter++;
        progress = (float)(i+1)/(float)arrayRutaCoord.count;
        //NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        
        //[tempArray addObject:coord];
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        
        
        NSLog(@"IdRuta: %d",_idRuta);
        NSLog(@"rutacoord_latitud: %f", _latitud);
        NSLog(@"rutacoord_longitud: %f", _longitud);
        //if(_idRuta==39)
        pointsToUse1[i] = CLLocationCoordinate2DMake(_latitud,_longitud);
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        //[tempArray addObject:coord];
        
    }
    NSLog(@"finished adding points");
    //[arrayRutaCoord removeAllObjects];
    NSString *lastChar = [titleRuta substringFromIndex:[titleRuta length] - 1];
    
    
    if([lastChar isEqualToString:@"1"]) pathColor = [UIColor greenColor];
    if([lastChar isEqualToString:@"2"]) pathColor = [UIColor orangeColor];
    if([lastChar isEqualToString:@"3"]) pathColor = [UIColor purpleColor];
    if([lastChar isEqualToString:@"4"]) pathColor = [UIColor blueColor];
    if([lastChar isEqualToString:@"5"]) pathColor = [UIColor redColor];
    if([lastChar isEqualToString:@"6"]) pathColor = [UIColor yellowColor];
    if([lastChar isEqualToString:@"7"]) pathColor = [UIColor grayColor];
    if([lastChar isEqualToString:@"8"]) pathColor = [UIColor magentaColor];
    if([lastChar isEqualToString:@"9"]) pathColor = [UIColor brownColor];
    if([lastChar isEqualToString:@"0"]) pathColor = [UIColor cyanColor];
    
    
    //if([lastChar isEqualToString:@"4"]) pathColor = [UIColor cyanColor];
    //if([lastChar isEqualToString:@"5"]) pathColor = [UIColor yellowColor];
    
    //MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount];
    //[self.map addOverlay:myPolyline level:MKOverlayLevelAboveRoads];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse1 count:283] level:MKOverlayLevelAboveRoads];
    //NSArray *subarray = [tempArray subarrayWithRange:NSMakeRange(0, 286)];
    //[self.map addOverlay:[MKPolyline polylineWithCoordinates:(__bridge CLLocationCoordinate2D *)(subarray) count:286] level:MKOverlayLevelAboveRoads];
    
    CLLocationCoordinate2D pointsToUse2[2700-284];
    NSLog(@"Points count %ld",(long)pointsCount);
    //NSMutableArray *tempArray2 = [[NSMutableArray alloc] init];
    int temp_counter2 = 0;
    //NSString *titleRuta2;//MKPolyline *myPolyline;
    for(int i = 284; i < 2700; i++) {
        temp_counter2++;
        progress = (float)(i+1)/(float)arrayRutaCoord.count;
        //NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        
        //[tempArray2 addObject:coord];
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        
        
        NSLog(@"IdRuta: %d",_idRuta);
        NSLog(@"rutacoord_latitud: %f", _latitud);
        NSLog(@"rutacoord_longitud: %f", _longitud);
        //if(_idRuta==39)
        pointsToUse2[i-284] = CLLocationCoordinate2DMake(_latitud,_longitud);
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        //[tempArray addObject:coord];
        
    }
    NSLog(@"finished adding points");
    //[arrayRutaCoord removeAllObjects];
    lastChar = [titleRuta substringFromIndex:[titleRuta length] - 1];
    
    
    if([lastChar isEqualToString:@"1"]) pathColor = [UIColor greenColor];
    if([lastChar isEqualToString:@"2"]) pathColor = [UIColor orangeColor];
    if([lastChar isEqualToString:@"3"]) pathColor = [UIColor purpleColor];
    if([lastChar isEqualToString:@"4"]) pathColor = [UIColor blueColor];
    if([lastChar isEqualToString:@"5"]) pathColor = [UIColor redColor];
    if([lastChar isEqualToString:@"6"]) pathColor = [UIColor yellowColor];
    if([lastChar isEqualToString:@"7"]) pathColor = [UIColor grayColor];
    if([lastChar isEqualToString:@"8"]) pathColor = [UIColor magentaColor];
    if([lastChar isEqualToString:@"9"]) pathColor = [UIColor brownColor];
    if([lastChar isEqualToString:@"0"]) pathColor = [UIColor cyanColor];
    
    
    //if([lastChar isEqualToString:@"4"]) pathColor = [UIColor cyanColor];
    //if([lastChar isEqualToString:@"5"]) pathColor = [UIColor yellowColor];
    
    //MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount];
    //[self.map addOverlay:myPolyline level:MKOverlayLevelAboveRoads];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse2 count:2700-284] level:MKOverlayLevelAboveRoads];
}
*/

- (void)setColorRuta:(NSString *)title{
    
    NSString *lastChar = [title substringFromIndex:[title length] - 1];
    
    
    if([lastChar isEqualToString:@"1"]) pathColor = [UIColor greenColor];
    if([lastChar isEqualToString:@"2"]) pathColor = [UIColor orangeColor];
    if([lastChar isEqualToString:@"3"]) pathColor = [UIColor purpleColor];
    if([lastChar isEqualToString:@"4"]) pathColor = [UIColor blueColor];
    if([lastChar isEqualToString:@"5"]) pathColor = [UIColor redColor];
    if([lastChar isEqualToString:@"6"]) pathColor = [UIColor yellowColor];
    if([lastChar isEqualToString:@"7"]) pathColor = [UIColor grayColor];
    if([lastChar isEqualToString:@"8"]) pathColor = [UIColor magentaColor];
    if([lastChar isEqualToString:@"9"]) pathColor = [UIColor brownColor];
    if([lastChar isEqualToString:@"0"]) pathColor = [UIColor cyanColor];
    
}

- (void)addRoute {
    
    float progress;
    
    //[self.progressView setProgress:progress];
    //int lastRuta = [[self getLastIdRuta] intValue];
    [self.progressView setProgress:0 animated:YES];
    oldIdRuta = 0;
    //int inicio = 0;
    //int ruta_counter = 0;
    NSInteger pointsCount = arrayRutaCoord.count;
    //CLLocationCoordinate2D [5][2];
    //CLLocationCoordinate2D pointsToUse[pointsCount];
    //CLLocationCoordinate2D *pointsToUse = malloc(sizeof(CLLocationCoordinate2D) * pointsCount);
    NSLog(@"Points count %ld",(long)pointsCount);
    //NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *countsArray = [[NSMutableArray alloc] init];
    //NSMutableArray *rutasArray[]
    int temp_counter = 0;
    int last_count = 0;
    NSString *titleRuta;//MKPolyline *myPolyline;
    for(int i = 0; i < pointsCount; i++) {
        temp_counter++;
        last_count = temp_counter;
        progress = (float)(i+1)/(float)arrayRutaCoord.count;
        //NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        
        //[tempArray addObject:coord];
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        
        NSLog(@"IdRuta: %d",_idRuta);
        NSLog(@"rutacoord_latitud: %f", _latitud);
        NSLog(@"rutacoord_longitud: %f", _longitud);
        //if(_idRuta==39)
        //pointsToUse[i] = CLLocationCoordinate2DMake(_latitud,_longitud);
        //[tempArray addObject:[NSValue valueWithCGPoint:CGPointMake(_latitud, _longitud)]];
        //[tempArray addObject:coord];
        
        if(_idRuta != oldIdRuta){
            if(oldIdRuta!=0){
                NSLog(@"CAMBIO!!");
                NSLog(@"Temp counter: %d",temp_counter);
                titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
                //[rutasArray addObject:(__bridge id)(malloc(sizeof(CLLocationCoordinate2D) * temp_counter))];
                //NSLog(@"ID RUTA: %@",titleRuta);
                //NSArray *subarray = [chunks subarrayWithRange:NSMakeRange(i, [keys count] - i)];
                //if(ruta_counter == 1)
                //CLLocationCoordinate2D tempPoints[temp_counter];
                //CLLocationCoordinate2D *tempPoints = malloc(sizeof(CLLocationCoordinate2D) * temp_counter);
                //NSLog(@"inicio: %d",inicio);
                //NSLog(@"i: %d",i);
                
                /*for(int j=inicio;j<i;j++)
                {
                    //CLLocationCoordinate2D *temp_point = (__bridge CLLocationCoordinate2D *)[tempArray objectAtIndex:j];
                    
                    NSDictionary *tempcoord = (NSDictionary *)[tempArray objectAtIndex:j];
                    //int _tidRuta = [[tempcoord objectForKey:@"IdRuta"] intValue];
                    float _tlatitud = [[tempcoord objectForKey:@"Latitud"] floatValue];
                    float _tlongitud = [[tempcoord objectForKey:@"Longitud"] floatValue];
                    tempPoints[j-inicio] = CLLocationCoordinate2DMake(_tlatitud,_tlongitud);
                    
                    //NSLog(@"j: %d",j);
                    //NSLog(@"IdRuta: %d",_tidRuta);
                    //CLLocationCoordinate2D *temp_point = tempPoints[j];
                    //NSLog(@"temp point: %@", tempPoints[j]);
                    //NSLog(@"t rutacoord_longitud: %f", _tlongitud);
                    //NSLog(@"t rutacoord_latitud: %f", _tlatitud);
                }*/
                [countsArray addObject:[NSNumber numberWithInt:temp_counter]];

            }

            
            temp_counter = 0;
            //inicio = i;
        }
        
        oldIdRuta = _idRuta;
    }
    
    NSLog(@"last counter: %d",last_count);
    [countsArray addObject:[NSNumber numberWithInt:last_count]];
    
    NSLog(@"finished adding points");
    
    int x = 0;
    int pointsCount1 = [[countsArray objectAtIndex:0] intValue];
    NSLog(@"Points count 1: %d",pointsCount1);
    CLLocationCoordinate2D pointsToUse1[pointsCount1];
    for(int i = x;i<pointsCount1;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i+x];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse1[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
NSLog(@"Ruta id: %@",titleRuta);
    //[arrayRutaCoord removeAllObjects];
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse1 count:pointsCount1] level:MKOverlayLevelAboveRoads];
    
    x += pointsCount1;
    int pointsCount2 = [[countsArray objectAtIndex:1] intValue];
    NSLog(@"Points count 2: %d",pointsCount2);
    CLLocationCoordinate2D pointsToUse2[pointsCount2];
    for(int i = x;i<pointsCount2+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse2[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    NSLog(@"Ruta id: %@",titleRuta);
    //[arrayRutaCoord removeAllObjects];
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse2 count:pointsCount2] level:MKOverlayLevelAboveRoads];
    
    x += pointsCount2;
    int pointsCount3 = [[countsArray objectAtIndex:2] intValue];
    NSLog(@"Points count 3: %d",pointsCount3);
    CLLocationCoordinate2D pointsToUse3[pointsCount3];
    for(int i = x;i<pointsCount3+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse3[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    NSLog(@"Ruta id: %@",titleRuta);
    //[arrayRutaCoord removeAllObjects];
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse3 count:pointsCount3] level:MKOverlayLevelAboveRoads];
    
    x += pointsCount3;
    int pointsCount4 = [[countsArray objectAtIndex:3] intValue];
    NSLog(@"Points count 4: %d",pointsCount4);
    CLLocationCoordinate2D pointsToUse4[pointsCount4];
    for(int i = x;i<pointsCount4+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse4[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    //[arrayRutaCoord removeAllObjects];
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse4 count:pointsCount4] level:MKOverlayLevelAboveRoads];
    
    
    x += pointsCount4;
    int pointsCount5 = [[countsArray objectAtIndex:4] intValue];
    NSLog(@"Points count 5: %d",pointsCount5);
    CLLocationCoordinate2D pointsToUse5[pointsCount5];
    for(int i = x;i<pointsCount5+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse5[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse5 count:pointsCount5] level:MKOverlayLevelAboveRoads];
    
    x += pointsCount5;
    int pointsCount6 = [[countsArray objectAtIndex:5] intValue];
    NSLog(@"Points count 6: %d",pointsCount6);
    CLLocationCoordinate2D pointsToUse6[pointsCount6];
    for(int i = x;i<pointsCount6+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse6[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse6 count:pointsCount6] level:MKOverlayLevelAboveRoads];
    
    x += pointsCount6;
    int pointsCount7 = [[countsArray objectAtIndex:6] intValue];
    NSLog(@"Points count 7: %d",pointsCount7);
    CLLocationCoordinate2D pointsToUse7[pointsCount7];
    for(int i = x;i<pointsCount7+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse7[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse7 count:pointsCount7] level:MKOverlayLevelAboveRoads];
    
    
    x += pointsCount7;
    int pointsCount8 = [[countsArray objectAtIndex:7] intValue];
    NSLog(@"Points count 8: %d",pointsCount8);
    CLLocationCoordinate2D pointsToUse8[pointsCount8];
    for(int i = x;i<pointsCount8+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse8[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse8 count:pointsCount8] level:MKOverlayLevelAboveRoads];
    
    
    x += pointsCount8;
    int pointsCount9 = [[countsArray objectAtIndex:8] intValue];
    NSLog(@"Points count 9: %d",pointsCount9);
    CLLocationCoordinate2D pointsToUse9[pointsCount9];
    for(int i = x;i<pointsCount9+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse9[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse9 count:pointsCount9] level:MKOverlayLevelAboveRoads];
    
    x += pointsCount9;
    int pointsCount10 = [[countsArray objectAtIndex:9] intValue];
    NSLog(@"Points count 10: %d",pointsCount10);
    CLLocationCoordinate2D pointsToUse10[pointsCount10];
    for(int i = x;i<pointsCount10+x;i++){
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        titleRuta = [NSString stringWithFormat:@"%d",_idRuta];
        float _latitud = [[coord objectForKey:@"Latitud"] floatValue];
        float _longitud = [[coord objectForKey:@"Longitud"] floatValue];
        pointsToUse10[i-x] = CLLocationCoordinate2DMake(_latitud,_longitud);
    }
    
    [self setColorRuta:titleRuta];
    
    [self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse10 count:pointsCount10] level:MKOverlayLevelAboveRoads];
    
    //if([lastChar isEqualToString:@"4"]) pathColor = [UIColor cyanColor];
    //if([lastChar isEqualToString:@"5"]) pathColor = [UIColor yellowColor];
    
    //MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount];
    //[self.map addOverlay:myPolyline level:MKOverlayLevelAboveRoads];
    
    //--[self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount] level:MKOverlayLevelAboveRoads];
    
    //[self.map addOverlay:[MKPolyline polylineWithCoordinates:pointsToUse1 count:pointsCount1] level:MKOverlayLevelAboveRoads];
    
    //NSArray *subarray = [tempArray subarrayWithRange:NSMakeRange(0, 286)];
    //[self.map addOverlay:[MKPolyline polylineWithCoordinates:(__bridge CLLocationCoordinate2D *)(subarray) count:286] level:MKOverlayLevelAboveRoads];
}

- (void) callAddRoute {
    
    /* Operation Queue init (autorelease) */
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(callAddRouteWithOperation)
                                                                              object:nil];
    
    /* Add the operation to the queue */
    [queue addOperation:operation];
    //[operation release];
}

- (void) callAddRouteWithOperation {
    [self addRoute];
}

-(void)mostrarGrupos{
    NSLog(@"Mostrar  Total grupos: %lu",(unsigned long)grupos.count);
    for(int i=0; i<grupos.count;i++){
        NSDictionary *itemGrupo = (NSDictionary *)[grupos objectAtIndex:i];
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        double latitud = [[itemGrupo objectForKey:@"Latitud"] doubleValue];
        double longitud = [[itemGrupo objectForKey:@"Longitud"] doubleValue];
        point.coordinate = CLLocationCoordinate2DMake(latitud, longitud);
        point.title = @"Grupo";
        point.subtitle = [itemGrupo objectForKey:@"Descripcion"];
        //NSLog(@"adding annotation: %@",point.subtitle);
        //NSLog(@"adding annotation latitud: %f",point.coordinate.latitude);
        //NSLog(@"adding annotation longitud: %f",point.coordinate.longitude);
        [self.map addAnnotation:point];
    }
}

- (void) GuardarRutas {
    
    /* Operation Queue init (autorelease) */
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(GuardarRutasWithOperation)
                                                                              object:nil];
    
    /* Add the operation to the queue */
    [queue addOperation:operation];
    //[operation release];
}

- (void) GuardarRutasWithOperation {
    float progress;
    
    //[self.progressView setProgress:progress];
    int lastRuta = [[self getLastIdRuta] intValue];
    for(int i=0; i<arrayRutaCoord.count;i++){
        progress = (float)(i+1)/(float)arrayRutaCoord.count;
        NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *rutaCoord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        float latitud = [[rutaCoord objectForKey:@"Latitud"] doubleValue];
        float longitud = [[rutaCoord objectForKey:@"Longitud"] doubleValue];
        NSLog(@"Insertando ruta: %d latitud: %f longitud: %f",lastRuta,latitud,longitud);
        [self InsertRutaCoord:lastRuta :latitud :longitud];
    }
    [self.statusIndicator setTitle:@"Listo"];
    [self.progressView setProgress:0];
    NSLog(@"Ruta almacenada exitosamente");
}

- (void) LoadAllRutas {
    
    /* Operation Queue init (autorelease) */
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(LoadAllRutasWithOperation)
                                                                              object:nil];
    
    /* Add the operation to the queue */
    [queue addOperation:operation];
    //[operation release];
}

- (void) LoadAllRutasWithOperation {
    float progress;
    
    //[self.progressView setProgress:progress];
    //int lastRuta = [[self getLastIdRuta] intValue];
    for(int i=0; i<rutas.count;i++){
        progress = (float)(i+1)/(float)rutas.count;
        //NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *ruta = (NSDictionary *)[rutas objectAtIndex:i];
        int idRuta = [[ruta objectForKey:@"IdRuta"] intValue];
        float latitudInicio = [[ruta objectForKey:@"LatitudInicio"] doubleValue];
        float longitudInicio = [[ruta objectForKey:@"LongitudInicio"] doubleValue];
        float latitudFin = [[ruta objectForKey:@"LatitudFin"] doubleValue];
        float longitudFin = [[ruta objectForKey:@"LongitudFin"] doubleValue];
        NSString *descInicio = [ruta objectForKey:@"DescInicio"];
        NSString *descFin = [ruta objectForKey:@"DescFin"];
        NSLog(@"Ruta: %d DescInicio: %@ latitudInicio: %f longitudInicio: %f descFin: %@ latitudFin: %f longitudFin: %f",idRuta,descInicio,latitudInicio,longitudInicio,descFin,latitudFin,longitudFin);
        
        MKPointAnnotation *pointInicio = [[MKPointAnnotation alloc] init];
        pointInicio.coordinate = CLLocationCoordinate2DMake(latitudInicio, longitudInicio);
        pointInicio.title = @"Inicio de Ruta";
        pointInicio.subtitle = descInicio;
        [self.map addAnnotation:pointInicio];
        
        MKPointAnnotation *pointFin = [[MKPointAnnotation alloc] init];
        pointFin.coordinate = CLLocationCoordinate2DMake(latitudFin, longitudFin);
        pointFin.title = @"Fin de Ruta";
        pointFin.subtitle = descFin;
        [self.map addAnnotation:pointFin];
        rutaCoordIdRuta = idRuta;
        //[id_rutas addObject:idRuta];
        
    }
    //[self callGetRutaCoord];
    [self.statusIndicator setTitle:@"Listo"];
    [self.progressView setProgress:0];
    NSLog(@"Rutas trazadas exitosamente");
    
}

- (void) LoadCoordenadas {
    
    /* Operation Queue init (autorelease) */
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(LoadCoordenadasWithOperation)
                                                                              object:nil];
    
    /* Add the operation to the queue */
    [queue addOperation:operation];
    //[operation release];
}

- (void) LoadCoordenadasWithOperation {
    float progress;
    
    //[self.progressView setProgress:progress];
    //int lastRuta = [[self getLastIdRuta] intValue];
    [self.progressView setProgress:0 animated:YES];
    oldIdRuta = 0;
    for(int i=0; i<arrayRutaCoord.count;i++){
        progress = (float)(i+1)/(float)arrayRutaCoord.count;
        //NSLog(@"Progress: %f",progress);
        [self.progressView setProgress:progress animated:YES];
        NSDictionary *coord = (NSDictionary *)[arrayRutaCoord objectAtIndex:i];
        int _idRuta = [[coord objectForKey:@"IdRuta"] intValue];
        //if(_idRuta != oldIdRuta) NSLog(@"CAMBIO!!");
        
        float _latitud = [[coord objectForKey:@"Latitud"] doubleValue];
        float _longitud = [[coord objectForKey:@"Longitud"] doubleValue];
        
        /*if(_idRuta != oldIdRuta){
        //_crumbs = [[CrumbPath alloc] initWithCenterCoordinate:CLLocationCoordinate2DMake(_latitud, _longitud)];
            if(_idRuta == 34) self.crumbView.pathColor = [UIColor redColor];
        }*/
        
        
        //if(_idRuta == 25) self.crumbView.pathColor = [UIColor redColor];
        //if(_idRuta == 34) self.crumbView.pathColor = [UIColor blueColor];
        
        //NSLog(@"LatitudInicio: %f longitudInicio: %f descFin: %@ latitudFin: %f longitudFin: %f",idRuta,descInicio,latitudInicio,longitudInicio,descFin,latitudFin,longitudFin);
        NSLog(@"IdRuta: %d",_idRuta);
        NSLog(@"rutacoord_latitud: %f", _latitud);
        NSLog(@"rutacoord_longitud: %f", _longitud);
        
        //if(_idRuta == oldIdRuta){
        if(_idRuta == 25){
        MKMapRect updateRect = [self.crumbs addCoordinate:CLLocationCoordinate2DMake(_latitud, _longitud)];
        //[self InsertRutaCoord:7 :newLocation.coordinate.latitude :newLocation.coordinate.latitude];
        
        
        //[arrayRutaCoord addObject:[NSDictionary dictionaryWithObjectsAndKeys:IdRuta,@"IdRuta",newLocation.coordinate.latitude,@"Latitud",newLocation.coordinate.longitude,@"Longitud",nil]];
        if (!MKMapRectIsNull(updateRect))
        {
            // There is a non null update rect.
            // Compute the currently visible map zoom scale
            MKZoomScale currentZoomScale = (CGFloat)(self.map.bounds.size.width / self.map.visibleMapRect.size.width);
            // Find out the line width at this zoom scale and outset the updateRect by that amount
            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
            // Ask the overlay view to update just the changed area.
            [self.crumbView setNeedsDisplayInMapRect:updateRect];
        }
        }
        oldIdRuta = _idRuta;
    }
    //[self.statusIndicator setTitle:@"Listo"];
    [self.progressView setProgress:0 animated:YES];
    NSLog(@"Ruta trazadas exitosamente");
}

- (void) callGetRutaCoord {
    
    /* Operation Queue init (autorelease) */
    NSOperationQueue *queue = [NSOperationQueue new];
    
    /* Create our NSInvocationOperation to call loadDataWithOperation, passing in nil */
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(callGetRutaCoordWithOperation)
                                                                              object:nil];
    
    /* Add the operation to the queue */
    [queue addOperation:operation];
    //[operation release];
}

- (void) callGetRutaCoordWithOperation {
    for(int i=0;i<rutas.count;i++)
    {
        //progress = (float)(i+1)/(float)rutas.count;
        //NSLog(@"Progress: %f",progress);
        //[self.progressView setProgress:progress animated:YES];
        NSDictionary *ruta = (NSDictionary *)[rutas objectAtIndex:i];
        int idRuta = [[ruta objectForKey:@"IdRuta"] intValue];
        [self getRutaCoord:idRuta];
    }
}

// Parsing the XML message list

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"element: %@",elementName);
	if ( [elementName isEqualToString:@"grupo"] ) {
		grupo_Descripcion = [attributeDict objectForKey:@"Descripcion"];
		grupo_IdGrupo = [[attributeDict objectForKey:@"IdGrupo"] intValue];
		grupo_Latitud = [[NSMutableString alloc] init];
		grupo_Longitud = [[NSMutableString alloc] init];
		inLatitud = NO;
		inLongitud = NO;
	}
    if ( [elementName isEqualToString:@"ruta"] ) {
		IdRuta = [attributeDict objectForKey:@"IdRuta"];
        ruta_DescInicio = [attributeDict objectForKey:@"DescInicio"];
        ruta_DescFin = [attributeDict objectForKey:@"DescFin"];
		//grupo_IdGrupo = [[attributeDict objectForKey:@"IdGrupo"] intValue];
        ruta_LatitudInicio = [[NSMutableString alloc] init];
		ruta_LongitudInicio = [[NSMutableString alloc] init];
        ruta_LatitudFin = [[NSMutableString alloc] init];
		ruta_LongitudFin = [[NSMutableString alloc] init];
		inRutaLatitudInicio = NO;
		inRutaLongitudInicio = NO;
        inRutaLatitudFin = NO;
		inRutaLongitudFin = NO;
	}
    if ( [elementName isEqualToString:@"coordenada"] ) {
		//grupo_Descripcion = [attributeDict objectForKey:@"Descripcion"];
		//grupo_IdGrupo = [[attributeDict objectForKey:@"IdGrupo"] intValue];
		IdRuta = [attributeDict objectForKey:@"IdRuta"];
        grupo_Latitud = [[NSMutableString alloc] init];
		grupo_Longitud = [[NSMutableString alloc] init];
		inLatitud = NO;
		inLongitud = NO;
	}
    if([elementName isEqualToString:@"RutaCoord"]){
        NSLog(@"RUTA COORD :D");
        [arrayRutaCoord removeAllObjects];
    }
    if ( [elementName isEqualToString:@"Latitud"] ) {
		inLatitud = YES;
	}
	if ( [elementName isEqualToString:@"Longitud"] ) {
		inLongitud = YES;
	}
	if ( [elementName isEqualToString:@"LatitudInicio"] ) {
		inRutaLatitudInicio = YES;
	}
	if ( [elementName isEqualToString:@"LongitudInicio"] ) {
		inRutaLongitudInicio = YES;
	}
    if ( [elementName isEqualToString:@"LatitudFin"] ) {
		inRutaLatitudFin = YES;
	}
	if ( [elementName isEqualToString:@"LongitudFin"] ) {
		inRutaLongitudFin = YES;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ( inLatitud ) {
		[grupo_Latitud appendString:string];
	}
	if ( inLongitud ) {
		[grupo_Longitud appendString:string];
	}
    if ( inRutaLatitudInicio ) {
		[ruta_LatitudInicio appendString:string];
	}
	if ( inRutaLongitudInicio ) {
		[ruta_LongitudInicio appendString:string];
	}
    if ( inRutaLatitudFin ) {
		[ruta_LatitudFin appendString:string];
	}
	if ( inRutaLongitudFin ) {
		[ruta_LongitudFin appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ( [elementName isEqualToString:@"grupo"] ) {
		[grupos addObject:[NSDictionary dictionaryWithObjectsAndKeys:grupo_Descripcion,@"Descripcion",grupo_Latitud,@"Latitud",grupo_Longitud,@"Longitud",nil]];
		NSLog(@"Grupo: %@", grupo_Descripcion);
        NSLog(@"Grupo_latitud: %@", grupo_Latitud);
        NSLog(@"Grupo_longitud: %@", grupo_Longitud);
		//lastId = msgId;
		
		//[msgAdded release];
		//[msgUser release];
		//[msgText release];
	}
    if ( [elementName isEqualToString:@"ruta"] ) {
		[rutas addObject:[NSDictionary dictionaryWithObjectsAndKeys:IdRuta,@"IdRuta",ruta_DescInicio,@"DescInicio",ruta_DescFin,@"DescFin",ruta_LatitudInicio,@"LatitudInicio",ruta_LongitudInicio,@"LongitudInicio",ruta_LatitudFin,@"LatitudFin",ruta_LongitudFin,@"LongitudFin",nil]];
		NSLog(@"Ruta: %@", IdRuta);
		//lastId = msgId;
		
		//[msgAdded release];
		//[msgUser release];
		//[msgText release];
	}
    if ( [elementName isEqualToString:@"coordenada"] ) {
        //if([IdRuta isEqualToString:@"34"])//XDE
        [arrayRutaCoord addObject:[NSDictionary dictionaryWithObjectsAndKeys:IdRuta,@"IdRuta",grupo_Latitud,@"Latitud",grupo_Longitud,@"Longitud",nil]];
		//NSLog(@"Grupo: %@", grupo_Descripcion);
        //NSLog(@"rutacoord_latitud: %@", grupo_Latitud);
        //NSLog(@"rutacoord_longitud: %@", grupo_Longitud);
		//lastId = msgId;
		
		//[msgAdded release];
		//[msgUser release];
		//[msgText release];
	}
	if ( [elementName isEqualToString:@"Latitud"] ) {
		inLatitud = NO;
	}
	if ( [elementName isEqualToString:@"Longitud"] ) {
		inLatitud = NO;
	}
    if ( [elementName isEqualToString:@"LatitudInicio"] ) {
		inRutaLatitudInicio = NO;
	}
	if ( [elementName isEqualToString:@"LongitudInicio"] ) {
		inRutaLongitudInicio = NO;
	}
    if ( [elementName isEqualToString:@"LatitudFin"] ) {
		inRutaLatitudFin = NO;
	}
	if ( [elementName isEqualToString:@"LongitudFin"] ) {
		inRutaLongitudFin = NO;
	}
}

-(void)InsertRutaCoord:(int)Id_Ruta
                      :(double)Latitud :(double)Longitud
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/InsertRutaCoord.php"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"IdRuta=%d&Latitud=%f&Longitud=%f",
                       Id_Ruta,Latitud,Longitud] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [[NSError alloc] init];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

-(void)InsertGrupo:(NSString *)Descripcion
                  :(double)Latitud :(double)Longitud
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *url = [NSString stringWithFormat:@"http://correofd.com/Pray_Mapp/InsertGrupo.php"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"Descripcion=%@&Latitud=%f&Longitud=%f",
                       Descripcion,Latitud,Longitud] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [[NSError alloc] init];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

-(void)limpiar
{
    self.crumbs = nil;
    [self.map removeOverlays:[self.map overlays]];
    [self.map removeAnnotations:self.map.annotations];
    [arrayRutaCoord removeAllObjects];
    [grupos removeAllObjects];
    [rutas removeAllObjects];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"%ld",(long)buttonIndex);
    if(buttonIndex == 0) //limpiar
    {
        [self limpiar];
    }
    if(buttonIndex == 1)//inicio de ruta
    {
        UIAlertView *inputRuta = [[UIAlertView alloc] initWithTitle:@"Crear Ruta" message:@"Descripción de la ubicación:" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ok", nil];
        inputRuta.alertViewStyle = UIAlertViewStylePlainTextInput;
        [inputRuta textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [inputRuta textFieldAtIndex:0].autocorrectionType = UITextAutocorrectionTypeYes;
        if(tracking == NO)
        {
            
            inputRuta.tag = 0;
            
        }
        else
        {
            inputRuta.tag = 1;
        }
        
        [inputRuta show];

    }
    else if(buttonIndex == 2)//fin de ruta
    {
        UIAlertView *inputRuta = [[UIAlertView alloc] initWithTitle:@"Crear Ruta" message:@"Descripción de la ubicación:" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ok", nil];
        inputRuta.alertViewStyle = UIAlertViewStylePlainTextInput;
        [inputRuta textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [inputRuta textFieldAtIndex:0].autocorrectionType = UITextAutocorrectionTypeYes;
        if(tracking == NO)
        {
            
            inputRuta.tag = 0;
            
        }
        else
        {
            inputRuta.tag = 1;
        }
        
        [inputRuta show];
    }
    else if(buttonIndex == 3)//nueva nota
    {
        UIAlertView *inputGrupo = [[UIAlertView alloc] initWithTitle:@"Nuevo Grupo" message:@"Descripción del grupo:" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ok", nil];
        inputGrupo.alertViewStyle = UIAlertViewStylePlainTextInput;
        [inputGrupo textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [inputGrupo textFieldAtIndex:0].autocorrectionType = UITextAutocorrectionTypeYes;
        inputGrupo.tag = 2;
        [inputGrupo show];
    }
    else if(buttonIndex == 4)//mostrar notas
    {
        [self getGrupos];
        //MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:<#(CLLocationCoordinate2D *)#> count:<#(NSUInteger)#> count:10];
        //[_mapView addOverlay:polyLine];
    }
    else if(buttonIndex == 5)//mostrar rutas
    {
        //[self limpiar];
        //[self.locationManager startUpdatingLocation];
        [self getRutas];
        //[self getGrupos];
    }
    
}

- (IBAction)displayMenu:(UIBarButtonItem *)sender {
    UIActionSheet * action = [[UIActionSheet alloc]initWithTitle:@""
                                                        delegate:self
                                                cancelButtonTitle: @"Cancelar"
                                                destructiveButtonTitle: @"Limpiar"
                                                otherButtonTitles: @"Inicio de Ruta", @"Fin de Ruta",@"Nueva nota",@"Mostrar notas",@"Mostrar Rutas",nil];
    [action showFromBarButtonItem:self.menuButton animated:YES];
}
- (IBAction)cambioMapa:(id)sender {
    switch (self.mapTypeSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.map.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.map.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.map.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}
@end
