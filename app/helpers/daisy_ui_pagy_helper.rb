module DaisyUiPagyHelper
    def pagy_daisy_ui_nav(pagy, pagy_id: nil, link_extra: '', **vars)
      p_id   = %( id="#{pagy_id}") if pagy_id
      p_prev = pagy.prev
      p_next = pagy.next
  
      html = +%(<div#{p_id} class="join">)
      html << if p_prev
                %(<a class="join-item btn" href="#{pagy_url_for(pagy, p_prev, html_escaped: true)}" aria-label="previous" #{link_extra}>#{I18n.t('pagy.nav.previous')}</a>)
              else
                %(<button class="join-item btn btn-disabled">#{I18n.t('pagy.nav.previous')}</button>)
              end
      pagy.series(**vars).each do |item|
        html << case item
                when Integer then %(<a class="join-item btn" href="#{pagy_url_for(pagy, item, html_escaped: true)}" #{link_extra}>#{item}</a>)
                when String  then %(<button class="join-item btn btn-active">#{pagy.label_for(item)}</button>)
                when :gap    then %(<button class="join-item btn btn-disabled">#{I18n.t('pagy.nav.gap')}</button>)
                else raise StandardError, "expected item types in series to be Integer, String or :gap; got #{item.inspect}"
                end
      end
      html << if p_next
                %(<a class="join-item btn" href="#{pagy_url_for(pagy, p_next, html_escaped: true)}" aria-label="next" #{link_extra}>#{I18n.t('pagy.nav.next')}</a>)
              else
                %(<button class="join-item btn btn-disabled">#{I18n.t('pagy.nav.next')}</button>)
              end
      html << %(</div>)
    end
  end
