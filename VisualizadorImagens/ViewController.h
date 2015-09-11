//
//  ViewController.h
//  VisualizadorImagens
//
//  Created by Fabricio Nogueira dos Santos on 9/11/15.
//  Copyright (c) 2015 Fabricio Nogueira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIScrollViewDelegate>{
    int paginaAtual;
}

@property (retain, nonatomic) NSMutableArray *imagens;
@property (retain, nonatomic) NSArray *elementos;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;

@end

