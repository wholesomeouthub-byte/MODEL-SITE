/**
 * JavaScript principal - UX Moderno para Site de Games
 * Seguindo heurísticas de Nielsen
 */

class GameNewsSite {
    constructor() {
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.initLazyLoading();
        this.setupAccessibility();
        this.setupInfiniteScroll();
        this.setupShareButtons();
    }

    // Heurística #1: Visibilidade do status do sistema
    setupEventListeners() {
        // Feedback visual para interações
        document.addEventListener('click', (e) => {
            if (e.target.matches('.save-article')) {
                this.handleSaveArticle(e);
            }
            
            if (e.target.matches('.share-article')) {
                this.handleShare(e);
            }
        });

        // Navegação por teclado
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeAllMenus();
            }
        });
    }

    // Heurística #3: Controle e liberdade do usuário
    async handleSaveArticle(event) {
        const button = event.currentTarget;
        const articleId = button.dataset.articleId;
        
        // Feedback imediato
        button.classList.add('saving');
        button.setAttribute('aria-label', 'Salvando...');
        
        try {
            const response = await fetch(ajax_object.ajax_url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    action: 'save_article',
                    article_id: articleId,
                    nonce: ajax_object.nonce
                })
            });
            
            const data = await response.json();
            
            // Feedback visual
            button.classList.remove('saving');
            if (data.saved) {
                button.classList.add('saved');
                button.setAttribute('aria-label', 'Artigo salvo');
                this.showFeedback('Artigo salvo com sucesso!', 'success');
            }
            
        } catch (error) {
            this.showFeedback('Erro ao salvar artigo', 'error');
            button.classList.remove('saving');
        }
    }

    // Heurística #6: Reconhecimento em vez de lembrança
    setupShareButtons() {
        document.querySelectorAll('.share-option').forEach(button => {
            button.addEventListener('click', (e) => {
                const type = e.currentTarget.dataset.share;
                this.shareArticle(type);
            });
        });
    }

    shareArticle(type) {
        const articleUrl = window.location.href;
        const articleTitle = document.title;
        
        switch(type) {
            case 'twitter':
                window.open(`https://twitter.com/share?url=${encodeURIComponent(articleUrl)}&text=${encodeURIComponent(articleTitle)}`, '_blank');
                break;
            case 'facebook':
                window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(articleUrl)}`, '_blank');
                break;
            case 'link':
                navigator.clipboard.writeText(articleUrl);
                this.showFeedback('Link copiado para a área de transferência!', 'success');
                break;
        }
    }

    // Heurística #8: Design estético e minimalista
    initLazyLoading() {
        if ('IntersectionObserver' in window) {
            const lazyImages = document.querySelectorAll('.lazy-load');
            
            const imageObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        img.classList.remove('lazy-load');
                        imageObserver.unobserve(img);
                    }
                });
            });
            
            lazyImages.forEach(img => imageObserver.observe(img));
        }
    }

    // Heurística #4: Consistência e padrões
    setupAccessibility() {
        // Foco visível para elementos interativos
        document.addEventListener('focusin', (e) => {
            if (e.target.matches('button, a, input, [tabindex]')) {
                e.target.classList.add('focus-visible');
            }
        });

        document.addEventListener('focusout', (e) => {
            e.target.classList.remove('focus-visible');
        });

        // ARIA live regions para atualizações dinâmicas
        const liveRegion = document.createElement('div');
        liveRegion.setAttribute('aria-live', 'polite');
        liveRegion.setAttribute('aria-atomic', 'true');
        liveRegion.className = 'sr-only';
        document.body.appendChild(liveRegion);
    }

    // Heurística #7: Eficiência de uso
    setupInfiniteScroll() {
        let loading = false;
        let page = 2;
        
        window.addEventListener('scroll', () => {
            if (loading) return;
            
            const { scrollTop, scrollHeight, clientHeight } = document.documentElement;
            
            if (scrollTop + clientHeight >= scrollHeight - 500) {
                this.loadMorePosts(page);
                page++;
                loading = true;
            }
        });
    }

    async loadMorePosts(page) {
        try {
            const response = await fetch(`${window.location.pathname}page/${page}/`);
            const html = await response.text();
            
            const temp = document.createElement('div');
            temp.innerHTML = html;
            const newPosts = temp.querySelectorAll('.news-card');
            
            const container = document.querySelector('.news-grid');
            newPosts.forEach(post => {
                container.appendChild(post);
            });
            
            // Atualizar observadores de lazy loading
            this.initLazyLoading();
            
        } catch (error) {
            console.error('Erro ao carregar mais posts:', error);
        } finally {
            loading = false;
        }
    }

    // Feedback visual para usuário (Heurística #1)
    showFeedback(message, type = 'info') {
        const feedback = document.createElement('div');
        feedback.className = `feedback-notification feedback-${type}`;
        feedback.textContent = message;
        feedback.setAttribute('role', 'alert');
        
        document.body.appendChild(feedback);
        
        setTimeout(() => {
            feedback.classList.add('show');
        }, 10);
        
        setTimeout(() => {
            feedback.classList.remove('show');
            setTimeout(() => feedback.remove(), 300);
        }, 3000);
    }

    closeAllMenus() {
        document.querySelectorAll('[aria-expanded="true"]').forEach(el => {
            el.setAttribute('aria-expanded', 'false');
        });
        
        document.querySelectorAll('[role="menu"][hidden]').forEach(menu => {
            menu.setAttribute('hidden', 'true');
        });
    }
}

// Inicializar quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', () => {
    new GameNewsSite();
});