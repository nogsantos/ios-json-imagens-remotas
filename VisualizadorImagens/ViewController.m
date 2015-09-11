//
//  ViewController.m
//  VisualizadorImagens
//
//  Created by Fabricio Nogueira dos Santos on 9/11/15.
//  Copyright (c) 2015 Fabricio Nogueira. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface ViewController ()
@end

@implementation ViewController
/**
 * Inicialização e busca das imagens
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     * endereço de busca das imagens
     */
    NSString *url = @"http://bit.ly/livroios-500px";
    /*
     * instancia do gerenciador de busca das imagens
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    /*
     * Configura o request para lidar com dados JSON.
     */
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    /*
     * Realiza a busca das imagens
     */
    [manager
        GET:url
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, id json){
            _elementos = json[@"photos"];
            [self mostraMensagem:[NSString stringWithFormat:@"%d imagens encontradas", _elementos.count]];
            if (_elementos.count > 0) {
                [self inicializaScroll];
            }
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
             [self mostraMensagem:[NSString stringWithFormat:@"Erro: %@", [error localizedDescription]]];
        }
    ];
}
/**
 *
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/**
 * Método de inicialização do scroll, carregamento das imagens.
 */
-(void) inicializaScroll{
    /*
     * Definições do tamanho da tela
     */
    float largura = self.scroll.bounds.size.width;
    float altura  = self.scroll.bounds.size.height;
    /*
     * Define a área de rolagem horizontal como sendo o
     * tamanho do componente de scroll pelo número de imagem que temos.
     */
    self.scroll.contentSize = CGSizeMake(largura * _elementos.count, altura);
    /*
     * Habilita a rolagem
     */
    self.scroll.pagingEnabled = YES;
    /*
     * inicialização dos componentes de imagens.
     */
    _imagens = [[NSMutableArray alloc] init];
    /*
     * Cria todos os lugares onde uma imagem pode aparecer, 
     * para facilitar as coisas na hora de carregar a imagem de fato do Flickr.
     */
    int indice = 0;
    for (NSDictionary *item in _elementos) {
        CGRect posicao   = CGRectMake(indice++ * largura, 0, largura, altura);
        UIImageView *img = [[UIImageView alloc] initWithFrame:posicao];
        [_scroll addSubview:img];
        [_imagens addObject:img];
    }
    /*
     * Adiciona a primeira imagem para não ficar com a tela vazia
     */
    [self carregaImagemRemota:0];
}
/**
 * Recebe como argumento o índice da imagem a ser carregada, relativo ao conteúdo do array imagens,
 * pega a URL do dicionário criado pelo AFNetworking e solicita o download e posterior exibição da imagem na tela.
 */
-(void) carregaImagemRemota:(int) indice{
    NSDictionary *item      = _elementos[indice];
    NSDictionary *imageInfo = item[@"images"][0];
    NSString *url           = imageInfo[@"url"];
    
    NSLog(@"Carregando a URL %@", url);
    /*
     * paga a referência ao UIImageView e informa através da propriedade contentMode 
     * que a imagem deve ser renderizada de tal maniera que apreça por completo, porém respeitando as dimensões
     * da tela e as devidas proporções. Sem isso, a imagem teria um aspecto esticado, fora das proporções originais.
     */
    UIImageView *img = _imagens[indice];
    /*
     * Recurso do AFNetworking através do método setImageWithURL:
     * Este método não existe na API padrão do componente UIImageView, mas o framework - por meio do recurso Categorias - 
     * adiciona esta funcionalidade. 
     * Ela se encarrega de fazer o download da imagem em segundo plano e, caso ela já tenha sido baixada, ele utiliza o cache da mesma.
     * Dessa forma, chamadas a mesma imagem com o mesmo endereço fará apenas um único download.
     */
    img.contentMode  = UIViewContentModeScaleAspectFit;
    [img setImageWithURL: [NSURL URLWithString:url]];
}
/**
 * Método para carregar outras imagens a medida em que o usuário interagi com o scroll.
 */
-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    int x       = (int)self.scroll.contentOffset.x;
    int largura = self.scroll.frame.size.width;
    /*
     * Somente carrega a próxima imagem
     * caso o scroll tenha parado em uma página
     */
    if (x % largura == 0) {
        int pagina = x / largura;
        [self carregaImagemRemota:pagina];
    }
}
/**
 * Mensagem de alerta
 */
-(void) mostraMensagem:(NSString *) message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle     : @"Aviso"
                          message           : message
                          delegate          : nil
                          cancelButtonTitle : @"OK"
                          otherButtonTitles : nil
    ];
    [alert show];
}
/**
 * Reorganizar as imagens depois que a tela girar
 */
-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation)orientacao {
    float largura = self.scroll.frame.size.width;
    float altura  = self.scroll.frame.size.height;
    int   indice  = 0;
    /*
     * define o novo tamanho do scroll
     */
    self.scroll.contentSize = CGSizeMake(largura * _elementos.count, altura);
    /*
     * itera em cada subviews do scroll para colocá-las na nova posição.
     */
    for (UIImageView *img in self.scroll.subviews) {
        if (img.frame.size.width > 7 && img.frame.size.height > 7) {
            img.frame = CGRectMake(indice++ * largura, 0, largura, altura);
        }
    }
    /*
     * coloca o scroll na nova posição.
     */
    CGPoint novaPosicao = CGPointMake(largura * paginaAtual, 0);
    [_scroll setContentOffset:novaPosicao animated:YES];
}
/**
 * Permitir rotação para todas as orientações
 */
-(BOOL) shouldAutorotate {
    return YES;
}

@end
