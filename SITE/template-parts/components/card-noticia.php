<?php
/**
 * Card de notícia para games
 * Design moderno com micro-interações
 */
?>
<article class="news-card" data-post-id="<?php the_ID(); ?>" role="article">
    
    <!-- Indicador visual de categoria (Heurística #2) -->
    <div class="card-category">
        <?php 
        $categories = get_the_category();
        if (!empty($categories)) {
            echo '<span class="category-badge">' . esc_html($categories[0]->name) . '</span>';
        }
        ?>
    </div>
    
    <!-- Thumbnail com lazy loading -->
    <div class="card-image">
        <a href="<?php the_permalink(); ?>" aria-label="Ler notícia: <?php the_title_attribute(); ?>">
            <?php if (has_post_thumbnail()) : ?>
                <img 
                    src="<?php the_post_thumbnail_url('medium'); ?>" 
                    data-src="<?php the_post_thumbnail_url('large'); ?>" 
                    alt="<?php the_title_attribute(); ?>" 
                    class="lazy-load"
                    loading="lazy"
                >
            <?php else : ?>
                <div class="placeholder-image" role="img" aria-label="Imagem não disponível"></div>
            <?php endif; ?>
            
            <!-- Overlay para feedback visual -->
            <div class="image-overlay" aria-hidden="true"></div>
        </a>
    </div>
    
    <!-- Conteúdo do card -->
    <div class="card-content">
        <!-- Timestamp com tempo relativo -->
        <div class="card-meta">
            <time datetime="<?php echo get_the_date('c'); ?>" class="time-ago">
                <?php echo human_time_diff(get_the_time('U'), current_time('timestamp')) . ' atrás'; ?>
            </time>
            <span class="read-time">
                <?php echo estimate_reading_time(); ?> min de leitura
            </span>
        </div>
        
        <!-- Título com limite de caracteres -->
        <h3 class="card-title">
            <a href="<?php the_permalink(); ?>" class="title-link">
                <?php echo wp_trim_words(get_the_title(), 8, '...'); ?>
            </a>
        </h3>
        
        <!-- Resumo -->
        <div class="card-excerpt">
            <?php echo wp_trim_words(get_the_excerpt(), 20, '...'); ?>
        </div>
        
        <!-- Interações do usuário -->
        <div class="card-actions">
            <button class="save-article" aria-label="Salvar artigo" data-article-id="<?php the_ID(); ?>">
                <span class="icon-bookmark" aria-hidden="true"></span>
                <span class="sr-only">Salvar</span>
            </button>
            
            <button class="share-article" aria-label="Compartilhar" aria-expanded="false" aria-controls="share-<?php the_ID(); ?>">
                <span class="icon-share" aria-hidden="true"></span>
                <span class="sr-only">Compartilhar</span>
            </button>
            
            <!-- Menu de compartilhamento (aparece no hover/focus) -->
            <div class="share-dropdown" id="share-<?php the_ID(); ?>" role="menu" hidden>
                <button class="share-option" data-share="twitter" aria-label="Compartilhar no Twitter">Twitter</button>
                <button class="share-option" data-share="facebook" aria-label="Compartilhar no Facebook">Facebook</button>
                <button class="share-option" data-share="link" aria-label="Copiar link">Copiar Link</button>
            </div>
        </div>
    </div>
    
    <!-- Feedback visual para interações -->
    <div class="card-feedback" aria-live="polite"></div>
</article>