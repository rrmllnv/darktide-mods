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
        this.elements.profileNameInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.handleModalOk();
            } else if (e.key === 'Escape') {
                e.preventDefault();
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
        
        // Предотвращаем блокировку ввода - останавливаем распространение событий на поле ввода
        this.elements.profileNameInput.addEventListener('mousedown', (e) => {
            e.stopPropagation();
        });
        
        this.elements.profileNameInput.addEventListener('click', (e) => {
            e.stopPropagation();
        });
        
        this.elements.profileNameInput.addEventListener('focus', (e) => {
            e.stopPropagation();
        });
    }
    
    showModal(title, defaultValue = '', callback) {
        this.elements.modalTitle.textContent = title;
        this.modalCallback = callback;
        
        // Полностью очищаем все атрибуты и стили, которые могут блокировать
        const input = this.elements.profileNameInput;
        
        // Удаляем все блокирующие атрибуты
        input.removeAttribute('disabled');
        input.removeAttribute('readonly');
        input.removeAttribute('tabindex');
        
        // Очищаем все inline стили, которые могут блокировать
        input.style.pointerEvents = '';
        input.style.cursor = '';
        input.style.opacity = '';
        input.style.userSelect = '';
        input.style.webkitUserSelect = '';
        
        // Устанавливаем значение
        input.value = defaultValue || '';
        
        // Показываем модальное окно
        this.elements.profileDialog.classList.add('show');
        
        // Простая установка фокуса без лишних проверок
        setTimeout(() => {
            input.focus();
            if (defaultValue) {
                input.select();
            }
        }, 10);
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
