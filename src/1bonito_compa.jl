DOM.observe(compat_btns_dynamic) do btns
    if isempty(btns)
        return DOM.div()
    end

    questions = MBTI_QUESTIONS[mbti_value[]]

    return DOM.div([
        DOM.div(
            style="display: flex; align-items: center; gap: 0.7em;",
            btns[i],
            DOM.div(questions[i])
        ) for i in 1:length(btns)
    ])
end
