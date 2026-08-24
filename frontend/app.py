import streamlit as st
import httpx
import pandas as pd
import os

API_URL = os.getenv("API_URL", "http://localhost:8000")

st.set_page_config(page_title="Text2SQL", page_icon=":db:", layout="wide")
st.title("Text2SQL with Clarification Engine")

tab1, tab2 = st.tabs(["Chat", "Evaluation"])

with tab1:
    if "messages" not in st.session_state:
        st.session_state.messages = []
    if "pending_clarification" not in st.session_state:
        st.session_state.pending_clarification = None

    for msg in st.session_state.messages:
        with st.chat_message(msg["role"]):
            st.write(msg["content"])
            if msg.get("results"):
                st.dataframe(pd.DataFrame(msg["results"]), use_container_width=True)

    question = st.chat_input("Ask a question about your data...")

    if question:
        st.session_state.messages.append({"role": "user", "content": question})
        with st.chat_message("user"):
            st.write(question)

        with st.chat_message("assistant"):
            with st.spinner("Analyzing your question..."):
                try:
                    response = httpx.post(f"{API_URL}/query", json={"question": question}, timeout=120)
                    data = response.json()

                    if data.get("is_ambiguous"):
                        clarification = "I need some clarification:\n\n"
                        for i, q in enumerate(data["clarification_questions"], 1):
                            clarification += f"{i}. {q}\n"
                        st.write(clarification)
                        st.session_state.messages.append({"role": "assistant", "content": clarification})
                        st.session_state.pending_clarification = question

                    elif data.get("sql_query"):
                        st.code(data["sql_query"], language="sql")
                        st.info(data.get("explanation", ""))

                        with st.spinner("Executing query..."):
                            exec_response = httpx.post(f"{API_URL}/execute", json={"question": question}, timeout=120)
                            exec_data = exec_response.json()

                            if exec_data.get("error"):
                                st.error(f"Error: {exec_data['error']}")
                            elif exec_data.get("results"):
                                df = pd.DataFrame(exec_data["results"])
                                st.dataframe(df, use_container_width=True)
                                st.success(f"Returned {len(df)} rows")
                                st.session_state.messages.append({
                                    "role": "assistant",
                                    "content": f"SQL:\n{data['sql_query']}\n\n{data.get('explanation', '')}",
                                    "results": exec_data["results"]
                                })
                            else:
                                st.warning("No results returned")
                                st.session_state.messages.append({
                                    "role": "assistant",
                                    "content": f"SQL:\n{data['sql_query']}\n\n{data.get('explanation', '')}"
                                })

                except Exception as e:
                    st.error(f"Error: {str(e)}")

    if st.session_state.pending_clarification:
        clarification_answer = st.chat_input("Provide clarification...")
        if clarification_answer:
            original = st.session_state.pending_clarification
            st.session_state.messages.append({"role": "user", "content": clarification_answer})
            st.session_state.pending_clarification = None

            with st.chat_message("assistant"):
                with st.spinner("Generating and executing SQL..."):
                    try:
                        response = httpx.post(
                            f"{API_URL}/query",
                            json={"question": original, "clarification_answer": clarification_answer},
                            timeout=120
                        )
                        data = response.json()
                        if data.get("sql_query"):
                            st.code(data["sql_query"], language="sql")
                            st.info(data.get("explanation", ""))

                            with st.spinner("Executing query..."):
                                exec_response = httpx.post(
                                    f"{API_URL}/execute",
                                    json={"question": original, "clarification_answer": clarification_answer},
                                    timeout=120
                                )
                                exec_data = exec_response.json()

                                if exec_data.get("error"):
                                    st.error(f"Error: {exec_data['error']}")
                                elif exec_data.get("results"):
                                    df = pd.DataFrame(exec_data["results"])
                                    st.dataframe(df, use_container_width=True)
                                    st.success(f"Returned {len(df)} rows")
                                    st.session_state.messages.append({
                                        "role": "assistant",
                                        "content": f"SQL:\n{data['sql_query']}\n\n{data.get('explanation', '')}",
                                        "results": exec_data["results"]
                                    })
                                else:
                                    st.warning("No results returned")
                                    st.session_state.messages.append({
                                        "role": "assistant",
                                        "content": f"SQL:\n{data['sql_query']}\n\n{data.get('explanation', '')}"
                                    })
                    except Exception as e:
                        st.error(f"Error: {str(e)}")

with tab2:
    st.header("Evaluation: With vs Without Clarification Engine")

    with st.spinner("Loading evaluation results..."):
        try:
            response = httpx.get(f"{API_URL}/evaluation-results", timeout=10)
            data = response.json()

            if "error" in data:
                st.error(data["error"])
            else:
                summary = data["summary"]
                details = data["details"]

                st.subheader("Summary")
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric(
                        "Without Clarification",
                        f"{summary['without_clarification']['avg_accuracy']}%",
                        f"{summary['without_clarification']['valid_sql_percent']}% valid SQL"
                    )
                with col2:
                    st.metric(
                        "With Clarification",
                        f"{summary['with_clarification']['avg_accuracy']}%",
                        f"{summary['with_clarification']['valid_sql_percent']}% valid SQL"
                    )
                with col3:
                    st.metric(
                        "Improvement",
                        f"+{summary['improvement']['accuracy_gain']}%",
                        f"+{summary['improvement']['valid_sql_gain']}% valid SQL"
                    )

                st.subheader("Detailed Results")

                st.write("**Without Clarification Engine:**")
                no_clarify_data = []
                for r in details["without_clarification"]:
                    no_clarify_data.append({
                        "Question": r["question"],
                        "Accuracy": f"{r['accuracy']}%",
                        "Valid SQL": "Yes" if r["valid"] else "No",
                        "Generated SQL": r["sql"][:80] + "..." if r["sql"] else "Failed"
                    })
                st.dataframe(pd.DataFrame(no_clarify_data), use_container_width=True)

                st.write("**With Clarification Engine:**")
                with_clarify_data = []
                for r in details["with_clarification"]:
                    with_clarify_data.append({
                        "Question": r["question"],
                        "Clarification": r.get("clarification", ""),
                        "Accuracy": f"{r['accuracy']}%",
                        "Valid SQL": "Yes" if r["valid"] else "No",
                        "Generated SQL": r["sql"][:80] + "..." if r["sql"] else "Failed"
                    })
                st.dataframe(pd.DataFrame(with_clarify_data), use_container_width=True)

                st.subheader("How Accuracy is Measured")
                st.write("""
                - **Keyword Check**: Does the SQL contain expected keywords (SELECT, JOIN, GROUP BY, etc.)?
                - **Table Check**: Does the SQL use the correct tables?
                - **Column Check**: Do result columns match expected columns?
                - **Row Count Check**: Does result have expected number of rows?
                - **Accuracy Score**: Weighted average of all checks (0-100%)
                """)

        except Exception as e:
            st.error(f"Error loading evaluation results: {str(e)}")
            st.info("Make sure the backend is running with: uvicorn api.main:app --reload --port 8000")
