'use client';

import { useEffect } from 'react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  preventClose?: boolean;
}

export default function Modal({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  size = 'md',
  preventClose = false 
}: ModalProps) {
  
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !preventClose) {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose, preventClose]);

  if (!isOpen) return null;

  const sizeClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-xl'
  };

  return (
    <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div 
        className={`bg-white rounded-lg shadow-xl w-full ${sizeClasses[size]} max-h-90vh overflow-y-auto`}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">{title}</h3>
          {!preventClose && (
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>
        
        <div className="p-6">
          {children}
        </div>
      </div>
    </div>
  );
}

// Composant pour les modals de confirmation
interface ConfirmModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  type?: 'danger' | 'warning' | 'info';
  isLoading?: boolean;
}

export function ConfirmModal({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmText = 'Confirmer',
  cancelText = 'Annuler',
  type = 'danger',
  isLoading = false
}: ConfirmModalProps) {
  
  const typeStyles = {
    danger: {
      icon: '🗑️',
      confirmButton: 'bg-red-600 hover:bg-red-700 focus:ring-red-500',
      iconBg: 'bg-red-100',
      iconColor: 'text-red-600'
    },
    warning: {
      icon: '⚠️',
      confirmButton: 'bg-yellow-600 hover:bg-yellow-700 focus:ring-yellow-500',
      iconBg: 'bg-yellow-100',
      iconColor: 'text-yellow-600'
    },
    info: {
      icon: 'ℹ️',
      confirmButton: 'bg-blue-600 hover:bg-blue-700 focus:ring-blue-500',
      iconBg: 'bg-blue-100',
      iconColor: 'text-blue-600'
    }
  };

  const style = typeStyles[type];

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={title} size="sm" preventClose={isLoading}>
      <div className="text-center">
        <div className={`mx-auto flex items-center justify-center h-12 w-12 rounded-full ${style.iconBg} mb-4`}>
          <span className={`text-xl ${style.iconColor}`}>{style.icon}</span>
        </div>
        
        <div className="mb-6">
          <p className="text-gray-600">{message}</p>
        </div>

        <div className="flex space-x-3">
          <button
            type="button"
            onClick={onClose}
            disabled={isLoading}
            className="flex-1 bg-gray-300 hover:bg-gray-400 disabled:bg-gray-200 disabled:cursor-not-allowed text-gray-800 px-4 py-2 rounded-lg font-medium transition-colors"
          >
            {cancelText}
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={isLoading}
            className={`flex-1 ${style.confirmButton} disabled:opacity-50 disabled:cursor-not-allowed text-white px-4 py-2 rounded-lg font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2`}
          >
            {isLoading ? (
              <span className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                En cours...
              </span>
            ) : (
              confirmText
            )}
          </button>
        </div>
      </div>
    </Modal>
  );
}

// Composant pour les messages toast
interface ToastProps {
  message: string;
  type?: 'success' | 'error' | 'warning' | 'info';
  isVisible: boolean;
  onClose: () => void;
  duration?: number;
}

export function Toast({ 
  message, 
  type = 'success', 
  isVisible, 
  onClose, 
  duration = 3000 
}: ToastProps) {
  
  useEffect(() => {
    if (isVisible && duration > 0) {
      const timer = setTimeout(onClose, duration);
      return () => clearTimeout(timer);
    }
  }, [isVisible, duration, onClose]);

  const typeStyles = {
    success: {
      bg: 'bg-green-50 border-green-200',
      text: 'text-green-800',
      icon: '✅'
    },
    error: {
      bg: 'bg-red-50 border-red-200',
      text: 'text-red-800',
      icon: '❌'
    },
    warning: {
      bg: 'bg-yellow-50 border-yellow-200',
      text: 'text-yellow-800',
      icon: '⚠️'
    },
    info: {
      bg: 'bg-blue-50 border-blue-200',
      text: 'text-blue-800',
      icon: 'ℹ️'
    }
  };

  const style = typeStyles[type];

  if (!isVisible) return null;

  return (
    <div className={`fixed top-4 right-4 z-50 p-4 rounded-lg border ${style.bg} ${style.text} shadow-lg max-w-sm animate-in slide-in-from-right`}>
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <span>{style.icon}</span>
          <p className="text-sm font-medium">{message}</p>
        </div>
        <button
          onClick={onClose}
          className="ml-4 text-gray-400 hover:text-gray-600"
        >
          ✕
        </button>
      </div>
    </div>
  );
}