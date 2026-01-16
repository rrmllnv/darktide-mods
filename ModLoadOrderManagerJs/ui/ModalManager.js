// Менеджер модальных окон
export class ModalManager {
    constructor(elements) {
        this.elements = elements;
        this.modalCallback = null;
        this.init();
    }
    
    init() {
        // Привязка событий модального окна
        this.elements.modalOkBtn.addEventListener('click', () => this.handleModalOk());
        this.elements.modalCancelBtn.addEventListener('click', () => this.handleModalCancel());
        this.elements.profileNameInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.handleModalOk();
            } else if (e.key === 'Escape') {
                this.handleModalCancel();
            }
        });
        
        // Закрытие модального окна при клике вне его
        this.elements.profileDialog.addEventListener('click', (e) => {
            // Закрываем только если клик был по фону, а не по содержимому
            if (e.target === this.elements.profileDialog) {
                this.handleModalCancel();
            }
        });
        
        // Предотвращаем закрытие при клике на содержимое модального окна
        const modalContent = this.elements.profileDialog.querySelector('.modal-content');
        if (modalContent) {
            modalContent.addEventListener('click', (e) => {
                e.stopPropagation();
            });
        }
    }
    
    showModal(title, defaultValue = '', callback) {
        this.elements.modalTitle.textContent = title;
        this.modalCallback = callback;
        
        // Убеждаемся, что поле доступно и очищено
        this.elements.profileNameInput.disabled = false;
        this.elements.profileNameInput.readOnly = false;
        this.elements.profileNameInput.value = defaultValue || '';
        
        // Убираем любые атрибуты, которые могут блокировать ввод
        this.elements.profileNameInput.removeAttribute('readonly');
        this.elements.profileNameInput.removeAttribute('disabled');
        this.elements.profileNameInput.style.pointerEvents = 'auto';
        this.elements.profileNameInput.style.cursor = 'text';
        
        // Показываем модальное окно
        this.elements.profileDialog.classList.add('show');
        
        // Функция для установки фокуса
        const setFocus = () => {
            try {
                // Убеждаемся, что поле доступно
                this.elements.profileNameInput.disabled = false;
                this.elements.profileNameInput.readOnly = false;
                
                // Устанавливаем фокус
                this.elements.profileNameInput.focus();
                
                // Если есть значение по умолчанию, выделяем его
                if (defaultValue) {
                    this.elements.profileNameInput.select();
                }
                
                // Проверяем, что фокус установился
                if (document.activeElement !== this.elements.profileNameInput) {
                    // Пробуем через небольшой таймаут
                    setTimeout(() => {
                        this.elements.profileNameInput.focus();
                        if (defaultValue) {
                            this.elements.profileNameInput.select();
                        }
                    }, 50);
                }
            } catch (e) {
                console.error('Ошибка установки фокуса:', e);
            }
        };
        
        // Используем несколько попыток для гарантии фокуса
        // Первая попытка через requestAnimationFrame
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                setFocus();
            });
        });
        
        // Вторая попытка через setTimeout
        setTimeout(setFocus, 100);
        
        // Третья попытка через больший таймаут (на случай если что-то блокирует)
        setTimeout(setFocus, 200);
    }
    
    hideModal() {
        this.elements.profileDialog.classList.remove('show');
        this.elements.profileNameInput.value = '';
        this.modalCallback = null;
    }
    
    handleModalOk() {
        const value = this.elements.profileNameInput.value.trim();
        if (this.modalCallback) {
            this.modalCallback(value);
        }
        this.hideModal();
    }
    
    handleModalCancel() {
        if (this.modalCallback) {
            this.modalCallback(null);
        }
        this.hideModal();
    }
}
