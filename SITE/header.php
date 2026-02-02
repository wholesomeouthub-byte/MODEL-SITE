<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    
    <!-- Feedback de status (Heurística #1) -->
    <div id="loading-indicator" class="loading-indicator" aria-live="polite" aria-label="Carregando"></div>
    
    <!-- Skip link para acessibilidade (Heurística #7) -->
    <a class="skip-link" href="#main-content">Pular para o conteúdo principal</a>
    
    <header class="site-header">
        <div class="header-container">
            <!-- Logo com link para home -->
            <div class="logo">
                <a href="<?php echo home_url(); ?>" aria-label="Voltar para página inicial">
                    <?php if (has_custom_logo()) : ?>
                        <?php the_custom_logo(); ?>
                    <?php else : ?>
                        <h1><?php bloginfo('name'); ?></h1>
                    <?php endif; ?>
                </a>
            </div>
            
            <!-- Barra de busca acessível (Heurística #5) -->
            <div class="search-container">
                <button class="search-toggle" aria-expanded="false" aria-controls="search-form">
                    <span class="sr-only">Abrir busca</span>
                    🔍
                </button>
                <form id="search-form" class="search-form" role="search" method="get" action="<?php echo home_url('/'); ?>">
                    <label for="search-input" class="sr-only">Buscar notícias</label>
                    <input type="search" 
                           id="search-input" 
                           name="s" 
                           placeholder="Buscar notícias..." 
                           aria-label="Buscar notícias"
                           autocomplete="off">
                    <button type="submit" aria-label="Enviar busca">Buscar</button>
                </form>
            </div>
            
            <!-- Menu principal responsivo -->
            <nav class="main-navigation" aria-label="Navegação principal">
                <button class="menu-toggle" aria-expanded="false" aria-controls="primary-menu">
                    <span class="hamburger" aria-hidden="true"></span>
                    <span class="sr-only">Menu</span>
                </button>
                
                <?php
                wp_nav_menu(array(
                    'theme_location' => 'primary',
                    'menu_id' => 'primary-menu',
                    'container' => false,
                    'menu_class' => 'nav-menu',
                    'walker' => new Accessible_Walker_Nav_Menu()
                ));
                ?>
            </nav>
        </div>
        
        <!-- Menu de categorias para games -->
        <nav class="category-navigation" aria-label="Categorias de games">
            <ul class="category-menu">
                <?php
                $categories = get_categories(array(
                    'taxonomy' => 'category',
                    'orderby' => 'name',
                    'hide_empty' => true
                ));
                
                foreach ($categories as $category) {
                    echo sprintf(
                        '<li><a href="%s" class="category-link" data-category="%s">%s</a></li>',
                        get_category_link($category->term_id),
                        $category->slug,
                        $category->name
                    );
                }
                ?>
            </ul>
        </nav>
    </header>
    
    <main id="main-content" class="main-content">