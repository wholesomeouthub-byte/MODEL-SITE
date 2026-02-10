<?php
// Funções do tema

function game_news_setup() {
    // Suporte a título dinâmico
    add_theme_support( 'title-tag' );

    // Suporte a logos personalizados
    add_theme_support( 'custom-logo' );

    // Suporte a thumbnails (imagens destacadas)
    add_theme_support( 'post-thumbnails' );

    // Suporte a menus
    register_nav_menus( array(
        'primary' => __( 'Menu Principal', 'game-news' ),
        'footer'  => __( 'Menu do Rodapé', 'game-news' ),
    ) );
}
add_action( 'after_setup_theme', 'game_news_setup' );



function game_news_widgets_init() {
    register_sidebar( array(
        'name'          => __( 'Sidebar', 'game-news' ),
        'id'            => 'sidebar-1',
        'description'   => __( 'Adicione widgets aqui.', 'game-news' ),
        'before_widget' => '<section id="%1$s" class="widget %2$s">',
        'after_widget'  => '</section>',
        'before_title'  => '<h2 class="widget-title">',
        'after_title'   => '</h2>',
    ) );
}
add_action( 'widgets_init', 'game_news_widgets_init' );

// Função para tempo de leitura estimado
function estimate_reading_time() {
    $content = get_post_field('post_content', get_the_ID());
    $word_count = str_word_count(strip_tags($content));
    $reading_time = ceil($word_count / 200); // 200 palavras por minuto
    
    return max(1, $reading_time); // Mínimo de 1 minuto
}

// AJAX para carregar mais posts
add_action('wp_ajax_load_more_posts', 'load_more_posts');
add_action('wp_ajax_nopriv_load_more_posts', 'load_more_posts');
function load_more_posts() {
    $paged = $_POST['page'] ? intval($_POST['page']) : 1;
    
    $args = array(
        'post_type' => 'post',
        'post_status' => 'publish',
        'paged' => $paged,
        'posts_per_page' => 6
    );
    
    $query = new WP_Query($args);
    
    if ($query->have_posts()) {
        while ($query->have_posts()) {
            $query->the_post();
            get_template_part('template-parts/components/card-noticia');
        }
    }
    
    wp_die();
}

// Shortcode para lista de jogos populares
add_shortcode('jogos_populares', 'jogos_populares_shortcode');
function jogos_populares_shortcode() {
    ob_start();
    ?>
    <div class="popular-games-widget">
        <h3>🎮 Jogos em Destaque</h3>
        <div class="games-grid">
            <!-- Conteúdo dinâmico via API ou custom fields -->
        </div>
    </div>
    <?php
    return ob_get_clean();
}

// Personalizar a query principal para games
function game_news_custom_query($query) {
    if ($query->is_main_query() && !is_admin()) {
        if (is_home() || is_category()) {
            $query->set('posts_per_page', 12);
            $query->set('orderby', 'date');
            $query->set('order', 'DESC');
        }
    }
}
add_action('pre_get_posts', 'game_news_custom_query');

// Classe para menu acessível
class Accessible_Walker_Nav_Menu extends Walker_Nav_Menu {
    function start_lvl(&$output, $depth = 0, $args = null) {
        $indent = str_repeat("\t", $depth);
        $output .= "\n$indent<ul class=\"sub-menu\" role=\"menu\">\n";
    }

    function start_el(&$output, $item, $depth = 0, $args = null, $id = 0) {
        $indent = ($depth) ? str_repeat("\t", $depth) : '';

        $classes = empty($item->classes) ? array() : (array) $item->classes;
        $classes[] = 'menu-item-' . $item->ID;

        $class_names = join(' ', apply_filters('nav_menu_css_class', array_filter($classes), $item, $args));
        $class_names = $class_names ? ' class="' . esc_attr($class_names) . '"' : '';

        $id = apply_filters('nav_menu_item_id', 'menu-item-'. $item->ID, $item, $args);
        $id = $id ? ' id="' . esc_attr($id) . '"' : '';

        $output .= $indent . '<li' . $id . $class_names .'>';

        $attributes = ! empty($item->attr_title) ? ' title="'  . esc_attr($item->attr_title) .'"' : '';
        $attributes .= ! empty($item->target)     ? ' target="' . esc_attr($item->target     ) .'"' : '';
        $attributes .= ! empty($item->xfn)        ? ' rel="'    . esc_attr($item->xfn        ) .'"' : '';
        $attributes .= ! empty($item->url)        ? ' href="'   . esc_attr($item->url        ) .'"' : '';
        $attributes .= ' role="menuitem"';

        $item_output = $args->before;
        $item_output .= '<a'. $attributes .'>';
        $item_output .= $args->link_before . apply_filters('the_title', $item->title, $item->ID) . $args->link_after;
        $item_output .= '</a>';
        $item_output .= $args->after;

        $output .= apply_filters('walker_nav_menu_start_el', $item_output, $item, $depth, $args);
    }
}
?>
