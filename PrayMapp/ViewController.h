//
//  ViewController.h
//  PrayMapp
//
//  Created by Marco Guevara on 21/04/14.
//  Copyright (c) 2014 Wapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate,UIActionSheetDelegate>
{
    //int lastId;
    
    NSMutableData *receivedData;
    
    NSMutableArray *grupos;
    
    NSMutableArray *arrayRutaCoord;
    
    NSMutableArray *rutas;
    
    NSMutableArray *id_rutas;
    
    //NSMutableArray *coordenadas;
    
    NSTimer *timerInsertRuta;
    
    NSXMLParser *xmlParser;
    NSString *grupo_Descripcion;
    NSMutableString *grupo_Latitud;
    NSMutableString *grupo_Longitud;
    int grupo_IdGrupo;
    Boolean inLatitud;
    Boolean inLongitud;
    NSUInteger totalGrupos;
    NSUInteger totalRutas;
    
    UIColor *pathColor;
    
    int rutaCoordIdRuta;
    
    NSString *temp_Latitud;
    NSString *temp_Longitud;
    
    int oldIdRuta;
    NSMutableString *IdRuta;
    NSMutableString *ruta_LatitudInicio;
    NSMutableString *ruta_LongitudInicio;
    Boolean inRutaLatitudInicio;
    Boolean inRutaLongitudInicio;
    NSMutableString *ruta_LatitudFin;
    NSMutableString *ruta_LongitudFin;
    Boolean inRutaLatitudFin;
    Boolean inRutaLongitudFin;
    NSMutableString *ruta_DescInicio;
    NSMutableString *ruta_DescFin;
    
    UIActivityIndicatorView *activityView;
    
    double latitudInicial;
    double longitudInicial;
    NSString *DescInicio;
    
    //NSString *lastIdRuta;
    
    
}

typedef enum {
    MOSTRAR_GRUPOS,
    LAST_RUTA,
    ALL_RUTAS,
    TRAZAR_COORDENADAS
} Action;

@property (assign, nonatomic) BOOL tracking;
- (IBAction)displayMenu:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusIndicator;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)cambioMapa:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;

@end
