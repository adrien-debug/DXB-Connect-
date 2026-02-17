'use client'

import Modal from '@/components/Modal'
import { useAddToCart } from '@/hooks/useCart'
import { Product, supabaseAny as supabase, Supplier } from '@/lib/supabase'
import {
  AlertTriangle,
  Edit2,
  Package,
  Plus,
  Search,
  ShoppingCart,
  Trash2
} from 'lucide-react'
import { useEffect, useState } from 'react'
import { toast } from 'sonner'

const defaultProduct: Partial<Product> = {
  name: '',
  description: '',
  sku: '',
  price: 0,
  cost_price: 0,
  category: '',
  stock: 0,
  min_stock: 5,
  image_url: '',
  status: 'active',
  supplier_id: null
}

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([])
  const [suppliers, setSuppliers] = useState<Supplier[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('')
  const [supplierFilter, setSupplierFilter] = useState('')
  const [modalOpen, setModalOpen] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Partial<Product>>(defaultProduct)
  const [isEditing, setIsEditing] = useState(false)
  const [saving, setSaving] = useState(false)

  const addToCart = useAddToCart()

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    try {
      const [productsRes, suppliersRes] = await Promise.all([
        supabase
          .from('products')
          .select('*, supplier:suppliers(*)')
          .order('created_at', { ascending: false }),
        supabase
          .from('suppliers')
          .select('*')
          .eq('status', 'active')
          .order('name')
      ])

      if (productsRes.error) {
        console.error('[Products] Error fetching products:', productsRes.error.message)
        throw productsRes.error
      }
      if (suppliersRes.error) {
        console.error('[Products] Error fetching suppliers:', suppliersRes.error.message)
        throw suppliersRes.error
      }

      setProducts(productsRes.data || [])
      setSuppliers(suppliersRes.data || [])
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error'
      console.error('[Products] Error fetching data:', errorMessage)
      toast.error(`Erreur de chargement: ${errorMessage}`)
    } finally {
      setLoading(false)
    }
  }

  const categories = [...new Set(products.map(p => p.category).filter(Boolean))]

  const filteredProducts = products.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.sku?.toLowerCase().includes(search.toLowerCase()) ||
      p.description?.toLowerCase().includes(search.toLowerCase())
    const matchesCategory = !categoryFilter || p.category === categoryFilter
    const matchesSupplier = !supplierFilter || p.supplier_id === supplierFilter
    return matchesSearch && matchesCategory && matchesSupplier
  })

  const handleAdd = () => {
    setEditingProduct(defaultProduct)
    setIsEditing(false)
    setModalOpen(true)
  }

  const handleEdit = (product: Product) => {
    setEditingProduct(product)
    setIsEditing(true)
    setModalOpen(true)
  }

  const handleDelete = async (product: Product) => {
    if (!confirm(`Supprimer le produit "${product.name}" ?`)) return

    try {
      const { error } = await supabase.from('products').delete().eq('id', product.id)
      if (error) throw error
      setProducts(prev => prev.filter(p => p.id !== product.id))
      toast.success('Produit supprimé')
    } catch (error) {
      console.error('Error deleting product:', error)
      toast.error('Erreur lors de la suppression')
    }
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)

    try {
      if (isEditing && editingProduct.id) {
        const { error } = await supabase
          .from('products')
          .update({
            ...editingProduct,
            updated_at: new Date().toISOString()
          })
          .eq('id', editingProduct.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from('products').insert([editingProduct])
        if (error) throw error
      }

      await fetchData()
      setModalOpen(false)
      toast.success(isEditing ? 'Produit mis à jour' : 'Produit créé')
    } catch (error) {
      console.error('Error saving product:', error)
      toast.error('Erreur lors de la sauvegarde')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-sky-500 to-sky-600 flex items-center justify-center animate-pulse">
          <Package className="w-7 h-7 text-white" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="animate-fade-in-up">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-gray-800">Produits</h1>
            <p className="text-gray-400 text-sm mt-1">Catalogue produits fournisseurs</p>
          </div>
          <button
            onClick={handleAdd}
            className="
              flex items-center gap-2 px-5 py-2.5
              bg-gradient-to-r from-sky-600 to-sky-500
              text-white font-medium rounded-2xl
              shadow-md shadow-sky-500/20
              hover:shadow-lg hover:shadow-sky-500/25
              hover:-translate-y-0.5 active:translate-y-0
              transition-all duration-300
            "
          >
            <Plus size={18} />
            Nouveau produit
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-3xl p-5 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="relative flex-1 group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 group-focus-within:text-sky-500 transition-colors" size={18} />
            <input
              type="text"
              placeholder="Rechercher un produit..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 focus:bg-white transition-all placeholder:text-gray-300"
            />
          </div>
          <div className="flex gap-3">
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="px-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 appearance-none cursor-pointer min-w-[150px]"
            >
              <option value="">Toutes catégories</option>
              {categories.map(cat => (
                <option key={cat} value={cat!}>{cat}</option>
              ))}
            </select>
            <select
              value={supplierFilter}
              onChange={(e) => setSupplierFilter(e.target.value)}
              className="px-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-300 appearance-none cursor-pointer min-w-[180px]"
            >
              <option value="">Tous fournisseurs</option>
              {suppliers.map(s => (
                <option key={s.id} value={s.id}>{s.name}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Products Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {filteredProducts.map((product, index) => (
          <ProductCard
            key={product.id}
            product={product}
            index={index}
            onEdit={() => handleEdit(product)}
            onDelete={() => handleDelete(product)}
            onAddToCart={() => addToCart.mutate({ productId: product.id })}
          />
        ))}
      </div>

      {filteredProducts.length === 0 && (
        <div className="text-center py-16 animate-fade-in-up">
          <div className="w-16 h-16 rounded-2xl bg-gray-50 flex items-center justify-center mx-auto mb-4">
            <Package className="w-8 h-8 text-gray-300" />
          </div>
          <p className="text-gray-500 font-medium">Aucun produit trouvé</p>
          <p className="text-sm text-gray-400 mt-1">Ajoutez votre premier produit</p>
        </div>
      )}

      {/* Modal */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={isEditing ? 'Modifier le produit' : 'Nouveau produit'}
        size="lg"
      >
        <form onSubmit={handleSave} className="space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-600 mb-2">Nom du produit *</label>
              <input
                type="text"
                required
                value={editingProduct.name || ''}
                onChange={e => setEditingProduct(prev => ({ ...prev, name: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">SKU</label>
              <input
                type="text"
                value={editingProduct.sku || ''}
                onChange={e => setEditingProduct(prev => ({ ...prev, sku: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Fournisseur</label>
              <select
                value={editingProduct.supplier_id || ''}
                onChange={e => setEditingProduct(prev => ({ ...prev, supplier_id: e.target.value || null }))}
                className="select-premium"
              >
                <option value="">Aucun fournisseur</option>
                {suppliers.map(s => (
                  <option key={s.id} value={s.id}>{s.name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Prix de vente (€) *</label>
              <input
                type="number"
                step="0.01"
                required
                value={editingProduct.price || 0}
                onChange={e => setEditingProduct(prev => ({ ...prev, price: parseFloat(e.target.value) || 0 }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Prix d&apos;achat (€)</label>
              <input
                type="number"
                step="0.01"
                value={editingProduct.cost_price || 0}
                onChange={e => setEditingProduct(prev => ({ ...prev, cost_price: parseFloat(e.target.value) || 0 }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Catégorie</label>
              <input
                type="text"
                value={editingProduct.category || ''}
                onChange={e => setEditingProduct(prev => ({ ...prev, category: e.target.value }))}
                placeholder="ex: Électronique, Télécom..."
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Stock</label>
              <input
                type="number"
                value={editingProduct.stock || 0}
                onChange={e => setEditingProduct(prev => ({ ...prev, stock: parseInt(e.target.value) || 0 }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Stock minimum</label>
              <input
                type="number"
                value={editingProduct.min_stock || 5}
                onChange={e => setEditingProduct(prev => ({ ...prev, min_stock: parseInt(e.target.value) || 0 }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Statut</label>
              <select
                value={editingProduct.status || 'active'}
                onChange={e => setEditingProduct(prev => ({ ...prev, status: e.target.value as Product['status'] }))}
                className="select-premium"
              >
                <option value="active">Actif</option>
                <option value="inactive">Inactif</option>
                <option value="out_of_stock">Rupture de stock</option>
              </select>
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-600 mb-2">URL Image</label>
              <input
                type="url"
                value={editingProduct.image_url || ''}
                onChange={e => setEditingProduct(prev => ({ ...prev, image_url: e.target.value }))}
                placeholder="https://..."
                className="input-premium"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-2">Description</label>
            <textarea
              value={editingProduct.description || ''}
              onChange={e => setEditingProduct(prev => ({ ...prev, description: e.target.value }))}
              rows={3}
              className="input-premium resize-none"
            />
          </div>
          <div className="flex justify-end gap-3 pt-5 border-t border-gray-100">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="px-5 py-2.5 text-gray-500 hover:bg-gray-50 rounded-2xl transition-all font-medium"
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={saving}
              className="
                px-6 py-2.5
                bg-gradient-to-r from-sky-600 to-sky-500
                text-white font-medium rounded-2xl
                shadow-md shadow-sky-500/20
                hover:shadow-lg hover:shadow-sky-500/25 hover:-translate-y-0.5
                transition-all duration-300
                disabled:opacity-50 disabled:cursor-not-allowed
              "
            >
              {saving ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  )
}

function ProductCard({
  product,
  index,
  onEdit,
  onDelete,
  onAddToCart
}: {
  product: Product
  index: number
  onEdit: () => void
  onDelete: () => void
  onAddToCart: () => void
}) {
  const isLowStock = product.stock <= product.min_stock
  const isOutOfStock = product.stock === 0

  return (
    <div
      className="
        group bg-white rounded-3xl overflow-hidden
        shadow-sm hover:shadow-md border border-gray-100/50
        hover:-translate-y-1
        transition-all duration-300 ease-out
        animate-fade-in-up
      "
      style={{ animationDelay: `${0.15 + index * 0.02}s`, animationFillMode: 'backwards' }}
    >
      {/* Image */}
      <div className="relative h-40 sm:h-36 bg-gray-50 flex items-center justify-center overflow-hidden">
        {product.image_url ? (
          <img
            src={product.image_url}
            alt={product.name}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
        ) : (
          <Package className="w-10 h-10 text-gray-200" />
        )}

        {/* Status badges */}
        <div className="absolute top-2 sm:top-3 left-2 sm:left-3 flex flex-wrap gap-1.5 max-w-[calc(100%-5rem)]">
          {isOutOfStock && (
            <span className="px-2 py-1 bg-rose-500 text-white text-xs font-medium rounded-xl shadow-sm">
              Rupture
            </span>
          )}
          {!isOutOfStock && isLowStock && (
            <span className="px-2 py-1 bg-amber-100 text-amber-600 text-xs font-medium rounded-xl flex items-center gap-1 shadow-sm">
              <AlertTriangle size={10} className="flex-shrink-0" />
              <span className="hidden sm:inline">Stock bas</span>
              <span className="sm:hidden">Bas</span>
            </span>
          )}
        </div>

        {/* Quick actions */}
        <div className="absolute top-2 sm:top-3 right-2 sm:right-3 flex gap-1 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
          <button
            onClick={(e) => { e.stopPropagation(); onEdit(); }}
            className="p-2 bg-white rounded-xl text-gray-400 hover:text-sky-600 shadow-sm transition-all"
            aria-label="Modifier"
          >
            <Edit2 size={14} />
          </button>
          <button
            onClick={(e) => { e.stopPropagation(); onDelete(); }}
            className="p-2 bg-white rounded-xl text-gray-400 hover:text-rose-500 shadow-sm transition-all"
            aria-label="Supprimer"
          >
            <Trash2 size={14} />
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="p-4 sm:p-5">
        <div className="flex items-start justify-between gap-2 mb-2">
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-gray-800 text-sm sm:text-base truncate group-hover:text-sky-600 transition-colors">
              {product.name}
            </h3>
            {product.sku && (
              <p className="text-xs text-gray-400 truncate">SKU: {product.sku}</p>
            )}
          </div>
          <span className="flex-shrink-0 text-sm sm:text-base font-semibold text-sky-600 whitespace-nowrap">
            {product.price.toFixed(2)} €
          </span>
        </div>

        <div className="flex flex-wrap gap-2 mb-3">
          {product.category && (
            <span className="inline-block px-2 py-0.5 bg-gray-50 text-gray-500 text-xs rounded-lg">
              {product.category}
            </span>
          )}

          {/* Supplier badge */}
          {product.supplier && (
            <span className={`
              inline-flex items-center gap-1.5 px-2 py-1 rounded-xl text-xs font-medium
              ${product.supplier.api_status === 'connected'
                ? 'bg-emerald-50 text-emerald-600'
                : product.supplier.api_status === 'error'
                  ? 'bg-rose-50 text-rose-600'
                  : 'bg-gray-50 text-gray-500'
              }
            `}>
              <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${product.supplier.api_status === 'connected' ? 'bg-emerald-500' :
                  product.supplier.api_status === 'error' ? 'bg-rose-500' : 'bg-gray-300'
                }`} />
              <span className="truncate max-w-[120px]">{product.supplier.name}</span>
            </span>
          )}
        </div>

        <div className="flex items-center justify-between pt-3 border-t border-gray-50 gap-3">
          <span className={`text-xs sm:text-sm ${isLowStock ? 'text-amber-600' : 'text-gray-400'} whitespace-nowrap`}>
            Stock: <span className="font-medium">{product.stock}</span>
          </span>
          <button
            onClick={onAddToCart}
            disabled={isOutOfStock}
            className="
              flex items-center gap-1.5 px-3 py-2
              bg-gradient-to-r from-sky-600 to-sky-500
              text-white text-xs font-medium rounded-xl
              shadow-sm shadow-sky-500/20
              hover:shadow-md hover:shadow-sky-500/25 hover:-translate-y-0.5
              transition-all duration-200
              disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0
              whitespace-nowrap
            "
          >
            <ShoppingCart size={12} className="flex-shrink-0" />
            <span className="hidden sm:inline">Ajouter</span>
            <span className="sm:hidden">+</span>
          </button>
        </div>
      </div>
    </div>
  )
}
