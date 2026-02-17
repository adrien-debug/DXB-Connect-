'use client'

import { useState } from 'react'
import { Search, Plus, Edit2, Trash2, ChevronLeft, ChevronRight, MoreHorizontal } from 'lucide-react'

interface Column<T> {
  key: keyof T | string
  label: string
  render?: (item: T) => React.ReactNode
}

interface DataTableProps<T> {
  data: T[]
  columns: Column<T>[]
  onAdd?: () => void
  onEdit?: (item: T) => void
  onDelete?: (item: T) => void
  searchPlaceholder?: string
  title: string
  addLabel?: string
}

export default function DataTable<T extends { id: string }>({
  data,
  columns,
  onAdd,
  onEdit,
  onDelete,
  searchPlaceholder = 'Rechercher...',
  title,
  addLabel = 'Ajouter'
}: DataTableProps<T>) {
  const [search, setSearch] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  const filteredData = data.filter(item =>
    Object.values(item).some(value =>
      String(value).toLowerCase().includes(search.toLowerCase())
    )
  )

  const totalPages = Math.ceil(filteredData.length / itemsPerPage)
  const paginatedData = filteredData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  )

  const getValue = (item: T, key: string) => {
    const keys = key.split('.')
    let value: unknown = item
    for (const k of keys) {
      value = (value as Record<string, unknown>)?.[k]
    }
    return value
  }

  return (
    <div className="bg-white rounded-3xl overflow-hidden animate-fade-in-up shadow-sm border border-gray-100/50">
      {/* Header */}
      <div className="p-5 border-b border-gray-100">
        <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
          <div>
            <h2 className="text-base font-semibold text-gray-800">{title}</h2>
            <p className="text-sm text-gray-400 mt-0.5">{filteredData.length} résultat(s)</p>
          </div>
          
          <div className="flex gap-3 w-full sm:w-auto">
            {/* Search */}
            <div className="relative flex-1 sm:flex-initial group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 group-focus-within:text-violet-500 transition-colors" size={18} />
              <input
                type="text"
                placeholder={searchPlaceholder}
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value)
                  setCurrentPage(1)
                }}
                className="
                  pl-11 pr-4 py-2.5 
                  bg-gray-50 border border-gray-100 rounded-2xl 
                  w-full sm:w-72 
                  focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-300 focus:bg-white
                  transition-all duration-300
                  placeholder:text-gray-300
                "
              />
            </div>
            
            {/* Add button */}
            {onAdd && (
              <button
                onClick={onAdd}
                className="
                  flex items-center gap-2 px-5 py-2.5 
                  bg-gradient-to-r from-violet-600 to-violet-500
                  text-white font-medium rounded-2xl 
                  shadow-md shadow-violet-500/20
                  hover:shadow-lg hover:shadow-violet-500/25
                  hover:-translate-y-0.5 active:translate-y-0
                  transition-all duration-300 
                  whitespace-nowrap
                "
              >
                <Plus size={18} />
                <span>{addLabel}</span>
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="bg-gray-50/50">
              {columns.map((col) => (
                <th 
                  key={String(col.key)} 
                  className="px-5 py-3.5 text-left text-xs font-medium text-gray-400 uppercase tracking-wider"
                >
                  {col.label}
                </th>
              ))}
              {(onEdit || onDelete) && (
                <th className="px-5 py-3.5 text-right text-xs font-medium text-gray-400 uppercase tracking-wider">
                  Actions
                </th>
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {paginatedData.length === 0 ? (
              <tr>
                <td colSpan={columns.length + 1} className="px-5 py-16 text-center">
                  <div className="flex flex-col items-center gap-3">
                    <div className="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center">
                      <Search className="w-7 h-7 text-gray-300" />
                    </div>
                    <p className="text-gray-500 font-medium text-sm">Aucune donnée trouvée</p>
                    <p className="text-xs text-gray-400">Essayez une autre recherche</p>
                  </div>
                </td>
              </tr>
            ) : (
              paginatedData.map((item, index) => (
                <tr 
                  key={item.id} 
                  className="
                    group hover:bg-violet-50/30 
                    transition-colors duration-200
                    animate-fade-in-up
                  "
                  style={{ animationDelay: `${index * 0.02}s`, animationFillMode: 'backwards' }}
                >
                  {columns.map((col) => (
                    <td 
                      key={String(col.key)} 
                      className="px-5 py-4 text-sm text-gray-600"
                    >
                      {col.render ? col.render(item) : String(getValue(item, String(col.key)) ?? '-')}
                    </td>
                  ))}
                  {(onEdit || onDelete) && (
                    <td className="px-5 py-4 text-right">
                      <div className="flex gap-1 justify-end sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-200">
                        {onEdit && (
                          <button
                            onClick={() => onEdit(item)}
                            className="
                              p-2 rounded-xl
                              text-gray-400 hover:text-violet-600 
                              hover:bg-violet-50
                              transition-all duration-200
                            "
                            aria-label="Modifier"
                          >
                            <Edit2 size={15} />
                          </button>
                        )}
                        {onDelete && (
                          <button
                            onClick={() => onDelete(item)}
                            className="
                              p-2 rounded-xl
                              text-gray-400 hover:text-rose-500 
                              hover:bg-rose-50
                              transition-all duration-200
                            "
                            aria-label="Supprimer"
                          >
                            <Trash2 size={15} />
                          </button>
                        )}
                      </div>
                    </td>
                  )}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="p-4 sm:p-5 border-t border-gray-50">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
            <span className="text-xs sm:text-sm text-gray-400 order-2 sm:order-1">
              Page <span className="font-medium text-gray-600">{currentPage}</span> sur <span className="font-medium text-gray-600">{totalPages}</span>
            </span>
            
            <div className="flex items-center gap-1.5 order-1 sm:order-2">
              <button
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                disabled={currentPage === 1}
                className="
                  p-2 rounded-xl 
                  bg-gray-50 border border-gray-100
                  hover:bg-gray-100 hover:border-gray-200
                  disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-gray-50
                  transition-all duration-200
                "
                aria-label="Page précédente"
              >
                <ChevronLeft size={16} className="text-gray-500" />
              </button>
              
              {/* Page numbers */}
              <div className="hidden sm:flex items-center gap-1">
                {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                  let pageNum: number
                  if (totalPages <= 5) {
                    pageNum = i + 1
                  } else if (currentPage <= 3) {
                    pageNum = i + 1
                  } else if (currentPage >= totalPages - 2) {
                    pageNum = totalPages - 4 + i
                  } else {
                    pageNum = currentPage - 2 + i
                  }
                  
                  return (
                    <button
                      key={pageNum}
                      onClick={() => setCurrentPage(pageNum)}
                      className={`
                        w-9 h-9 rounded-xl font-medium text-sm
                        transition-all duration-200
                        ${currentPage === pageNum
                          ? 'bg-violet-600 text-white shadow-md shadow-violet-500/20'
                          : 'bg-gray-50 border border-gray-100 text-gray-500 hover:bg-gray-100 hover:border-gray-200'
                        }
                      `}
                      aria-label={`Page ${pageNum}`}
                    >
                      {pageNum}
                    </button>
                  )
                })}
              </div>
              
              <button
                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages}
                className="
                  p-2 rounded-xl 
                  bg-gray-50 border border-gray-100
                  hover:bg-gray-100 hover:border-gray-200
                  disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-gray-50
                  transition-all duration-200
                "
                aria-label="Page suivante"
              >
                <ChevronRight size={16} className="text-gray-500" />
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
