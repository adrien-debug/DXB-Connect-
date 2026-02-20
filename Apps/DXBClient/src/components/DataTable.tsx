'use client'

import { useState } from 'react'
import { Search, Plus, Edit2, Trash2, ChevronLeft, ChevronRight } from 'lucide-react'

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
    <div className="bg-zinc-900 rounded-3xl overflow-hidden animate-fade-in-up border border-zinc-800">
      {/* Header */}
      <div className="p-5 border-b border-zinc-800">
        <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
          <div>
            <h2 className="text-base font-semibold text-white">{title}</h2>
            <p className="text-sm text-zinc-500 mt-0.5">{filteredData.length} résultat(s)</p>
          </div>

          <div className="flex gap-3 w-full sm:w-auto">
            <div className="relative flex-1 sm:flex-initial group">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-600 group-focus-within:text-lime-400 transition-colors" size={18} />
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
                  bg-zinc-800 border border-zinc-700 rounded-2xl
                  w-full sm:w-72
                  focus:outline-none focus:ring-2 focus:ring-lime-400/20 focus:border-lime-400/50 focus:bg-zinc-800
                  transition-all duration-300
                  placeholder:text-zinc-600 text-zinc-200
                "
              />
            </div>

            {onAdd && (
              <button
                onClick={onAdd}
                className="
                  flex items-center gap-2 px-5 py-2.5
                  bg-lime-400 hover:bg-lime-300
                  text-zinc-950 font-semibold rounded-xl
                  shadow-md shadow-lime-400/20 hover:shadow-lg hover:shadow-lime-400/30
                  transition-all duration-200
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
            <tr className="bg-zinc-800/50">
              {columns.map((col) => (
                <th
                  key={String(col.key)}
                  className="px-5 py-3.5 text-left text-xs font-medium text-zinc-500 uppercase tracking-wider"
                >
                  {col.label}
                </th>
              ))}
              {(onEdit || onDelete) && (
                <th className="px-5 py-3.5 text-right text-xs font-medium text-zinc-500 uppercase tracking-wider">
                  Actions
                </th>
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-800/50">
            {paginatedData.length === 0 ? (
              <tr>
                <td colSpan={columns.length + 1} className="px-5 py-16 text-center">
                  <div className="flex flex-col items-center gap-3">
                    <div className="w-14 h-14 rounded-2xl bg-zinc-800 flex items-center justify-center">
                      <Search className="w-7 h-7 text-zinc-600" />
                    </div>
                    <p className="text-zinc-400 font-medium text-sm">Aucune donnée trouvée</p>
                    <p className="text-xs text-zinc-600">Essayez une autre recherche</p>
                  </div>
                </td>
              </tr>
            ) : (
              paginatedData.map((item, index) => (
                <tr
                  key={item.id}
                  className="
                    group hover:bg-zinc-800/30
                    transition-colors duration-200
                    animate-fade-in-up
                  "
                  style={{ animationDelay: `${index * 0.02}s`, animationFillMode: 'backwards' }}
                >
                  {columns.map((col) => (
                    <td
                      key={String(col.key)}
                      className="px-5 py-4 text-sm text-zinc-300"
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
                              text-zinc-500 hover:text-lime-400
                              hover:bg-lime-400/10
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
                              text-zinc-500 hover:text-rose-400
                              hover:bg-rose-500/10
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
        <div className="p-4 sm:p-5 border-t border-zinc-800">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
            <span className="text-xs sm:text-sm text-zinc-500 order-2 sm:order-1">
              Page <span className="font-medium text-zinc-300">{currentPage}</span> sur <span className="font-medium text-zinc-300">{totalPages}</span>
            </span>

            <div className="flex items-center gap-1.5 order-1 sm:order-2">
              <button
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                disabled={currentPage === 1}
                className="
                  p-2 rounded-xl
                  bg-zinc-800 border border-zinc-700
                  hover:bg-zinc-700 hover:border-zinc-600
                  disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-zinc-800
                  transition-all duration-200
                "
                aria-label="Page précédente"
              >
                <ChevronLeft size={16} className="text-zinc-400" />
              </button>

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
                          ? 'bg-lime-400 text-zinc-950 font-bold'
                          : 'bg-zinc-800 border border-zinc-700 text-zinc-400 hover:bg-zinc-700 hover:border-zinc-600'
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
                  bg-zinc-800 border border-zinc-700
                  hover:bg-zinc-700 hover:border-zinc-600
                  disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-zinc-800
                  transition-all duration-200
                "
                aria-label="Page suivante"
              >
                <ChevronRight size={16} className="text-zinc-400" />
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
