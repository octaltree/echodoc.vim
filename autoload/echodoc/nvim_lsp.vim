let g:echodoc#nvim_lsp#_last_signature = ''

function! s:use_nvim_lsp() abort
  let use_nvim_lsp = get(g:, 'echodoc#use_nvim_lsp', v:false)
  return !!use_nvim_lsp
endfunction

function! echodoc#nvim_lsp#fetch_cursor_signature_and_store(filetype) abort
  if !s:use_nvim_lsp()
    return
  endif
  " Request without blocking and use the response next time.
  lua <<EOF
  do
    local cur = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/signatureHelp", cur,
      function(err, _method, result, _client_id, _bufnr, _config)
        if not result then return end
        local signature = result.signatures[1]
        if not signature then return end
        -- Discard signature.parameters
        vim.g['echodoc#nvim_lsp#_last_signature'] = signature.label
      end)
  end
EOF
  let lines = split(copy(g:echodoc#nvim_lsp#_last_signature), '\n')
  if empty(lines) || lines[0] ==# ''
    return
  endif
  let signature = lines[0]
  let v_comp = echodoc#util#parse_funcs(signature, a:filetype)[0]
  if empty(v_comp)
    return
  endif
  let cache = echodoc#default#get_cache(a:filetype)
  let cache[v_comp.name] = v_comp
endfunction
